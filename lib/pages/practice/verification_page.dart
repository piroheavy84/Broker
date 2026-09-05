import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/practice_provider.dart';
import '../../services/broker_api.dart';
import 'results_page.dart';

class VerificationPage extends ConsumerStatefulWidget {
  const VerificationPage({super.key});

  @override
  ConsumerState<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends ConsumerState<VerificationPage> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? searchResponse;
  List<String> banks = [];
  final Map<String, Map<String, bool>> checks = {};
  final Map<String, String> notes = {};
  final Map<String, Map<String, dynamic>> sussistenzaDetails = {};
  final Map<String, Map<String, dynamic>> verificationDetails = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_analizza);
  }

  bool _globalRichiedentiOk() {
    final pratica = ref.read(practiceProvider);
    return pratica.richiedenti.isNotEmpty &&
        pratica.richiedenti.every(
          (r) => r.nome.trim().isNotEmpty && r.cognome.trim().isNotEmpty,
        );
  }

  bool _globalMutuoOk() => ref.read(practiceProvider).mortgage != null;

  Future<void> _analizza() async {
    final pratica = ref.read(practiceProvider);
    final richiedentiOk = _globalRichiedentiOk();
    final mutuoOk = _globalMutuoOk();

    if (!richiedentiOk || !mutuoOk) {
      if (mounted) {
        setState(() {
          loading = false;
          searchResponse = null;
        });
      }
      return;
    }

    try {
      final banksResponse = await BrokerApi.getBanks();
      final response = await BrokerApi.search(pratica);

      final bankRows = banksResponse['banks'] as List<dynamic>? ?? [];
      final loadedBanks = bankRows
          .map((e) => (e as Map)['banca']?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final prodotti = response['prodotti'] as List<dynamic>? ?? [];
      final newChecks = <String, Map<String, bool>>{};
      final newNotes = <String, String>{};

      for (final banca in loadedBanks) {
        final prodottiBanca = prodotti
            .where((p) => (p as Map)['banca']?.toString().toLowerCase() == banca.toLowerCase())
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList();

        final prodottoOk = prodottiBanca.isNotEmpty;
        final prodottiAmmessi = prodottiBanca
            .where((p) => p['semaforo']?.toString() != 'ROSSO')
            .toList();
        final bancaOk = prodottiAmmessi.isNotEmpty;

        bool etaOk = false;
        bool debitiOk = false;
        bool anniItaliaOk = false;
        bool rapportoOk = false;
        bool sussistenzaOk = false;

        if (prodottiBanca.isNotEmpty) {
          // Per i dettagli mostriamo preferibilmente un prodotto ammesso;
          // se non esiste, il primo prodotto della banca.
          final prodottoDettaglio =
              prodottiAmmessi.isNotEmpty ? prodottiAmmessi.first : prodottiBanca.first;
          final verificaDettaglio = prodottoDettaglio['verifica_parametri_banca'];
          verificationDetails[banca] = {
            'prodotto': prodottoDettaglio,
            'verifica': verificaDettaglio is Map
                ? Map<String, dynamic>.from(verificaDettaglio)
                : <String, dynamic>{},
          };

          etaOk = prodottiBanca.any((p) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) return false;
            final eta = verifica['eta'];
            return eta is Map && eta['ok'] == true;
          });

          debitiOk = prodottiBanca.any((p) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) return false;
            final debiti = verifica['debiti'];
            return debiti is Map && debiti['ok'] == true;
          });

          anniItaliaOk = prodottiBanca.any((p) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) return false;
            final v = verifica['anni_italia'];
            return v is Map && v['ok'] == true;
          });

          rapportoOk = prodottiBanca.any((p) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) return false;
            final v = verifica['rapporto_rata_reddito'];
            return v is Map && v['ok'] == true;
          });

          sussistenzaOk = prodottiBanca.any((p) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) return false;
            final v = verifica['sussistenza'];
            return v is Map && v['ok'] == true;
          });

          for (final p in prodottiBanca) {
            final verifica = p['verifica_parametri_banca'];
            if (verifica is! Map) continue;
            final s = verifica['sussistenza'];
            if (s is Map) {
              sussistenzaDetails[banca] =
                  Map<String, dynamic>.from(s);
              if (s['ok'] == true) break;
            }
          }
        }

        // Una banca passa solo se esiste almeno un suo prodotto che supera
        // contemporaneamente tutte le verifiche del backend.
        newChecks[banca] = {
          'Richiedente': richiedentiOk,
          'Mutuo': mutuoOk,
          'Prodotto': prodottoOk,
          'Debiti': debitiOk,
          'Età': etaOk,
          'Anni in Italia': anniItaliaOk,
          'Rapporto rata/reddito': rapportoOk,
          'Sussistenza': sussistenzaOk,
          'ESITO': bancaOk,
        };

        if (!prodottoOk) {
          newNotes[banca] = 'Nessun prodotto compatibile con i dati mutuo/finalità.';
        } else if (!bancaOk) {
          final motivi = <String>{};
          for (final p in prodottiBanca) {
            final m = p['motivi_esclusione'];
            if (m is List) {
              motivi.addAll(m.map((e) => e.toString()));
            }
          }
          newNotes[banca] = motivi.isEmpty
              ? 'La banca non supera almeno una verifica.'
              : motivi.join(' • ');
        } else {
          newNotes[banca] = '${prodottiAmmessi.length} prodotto/i ammesso/i.';
        }
      }

      if (!mounted) return;
      setState(() {
        banks = loadedBanks;
        checks
          ..clear()
          ..addAll(newChecks);
        notes
          ..clear()
          ..addAll(newNotes);
        searchResponse = response;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  bool _bankOk(String banca) => checks[banca]?['ESITO'] == true;

  Map<String, dynamic> _filteredResponse() {
    final original = Map<String, dynamic>.from(searchResponse ?? {});
    final prodotti = original['prodotti'] as List<dynamic>? ?? [];
    final filtrati = prodotti.where((p) {
      final map = p as Map;
      final banca = map['banca']?.toString() ?? '';
      return _bankOk(banca) && map['semaforo']?.toString() != 'ROSSO';
    }).toList();

    original['prodotti'] = filtrati;
    original['numero_prodotti'] = filtrati.length;
    original['migliore'] = filtrati.isEmpty ? null : filtrati.first;
    return original;
  }

  Widget _icon(bool ok) => Icon(
        ok ? Icons.check_circle : Icons.cancel,
        color: ok ? Colors.green : Colors.red,
        size: 22,
      );

  Widget _matrix() {
    const righe = ['Richiedente', 'Mutuo', 'Prodotto', 'Debiti', 'Età', 'Anni in Italia', 'Rapporto rata/reddito', 'Sussistenza'];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 58,
          columns: [
            const DataColumn(label: Text('VERIFICA')),
            ...banks.map(
              (b) => DataColumn(
                label: SizedBox(
                  width: 125,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      _icon(_bankOk(b)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          rows: [
            ...righe.map(
              (riga) => DataRow(
                cells: [
                  DataCell(Text(riga, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ...banks.map((b) => DataCell(Center(child: _icon(checks[b]?[riga] == true)))),
                ],
              ),
            ),
            DataRow(
              cells: [
                const DataCell(Text('BANCA AMMESSA', style: TextStyle(fontWeight: FontWeight.bold))),
                ...banks.map((b) => DataCell(Center(child: _icon(_bankOk(b))))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _eur(dynamic value) {
    final n = value is num ? value.toDouble() : double.tryParse('$value');
    if (n == null) return '-';
    return '€ ${n.toStringAsFixed(2)}';
  }

  Widget _sussistenzaDetail(String banca) {
    final d = sussistenzaDetails[banca];
    if (d == null) return const SizedBox.shrink();

    final componenti = d['componenti_nucleo'];
    final oltre = d['numero_incrementi_oltre_5'] ?? 0;
    final incremento = d['incremento_oltre_5'];
    final soglia5 = d['soglia_base_5'];
    final soglia = d['soglia'];

    String sogliaFormula = 'Soglia applicata: ${_eur(soglia)}';
    if (componenti is num &&
        componenti > 5 &&
        soglia5 != null &&
        incremento != null) {
      sogliaFormula =
          'Soglia: ${_eur(soglia5)} + ($oltre × ${_eur(incremento)}) = ${_eur(soglia)}';
    }

    return ExpansionTile(
      leading: Icon(
        d['ok'] == true ? Icons.check_circle : Icons.cancel,
        color: d['ok'] == true ? Colors.green : Colors.red,
      ),
      title: Text('Dettaglio sussistenza - $banca'),
      subtitle: Text(
        '${d['geografia'] ?? '-'} • ${componenti ?? '-'} componenti',
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tipo geografia: ${d['tipo_geografia'] ?? '-'}\n'
              'Geografia applicata: ${d['geografia'] ?? '-'}\n'
              'Richiedenti: ${d['numero_richiedenti'] ?? '-'}\n'
              'Persone a carico: ${d['persone_a_carico'] ?? '-'}\n'
              'Componenti nucleo: ${componenti ?? '-'}\n'
              '$sogliaFormula\n'
              'Reddito totale: ${_eur(d['reddito_totale'])}\n'
              'Rate debiti: ${_eur(d['rate_debiti'])}\n'
              'Rata nuovo mutuo: ${_eur(d['rata_mutuo'])}\n'
              'Reddito residuo: ${_eur(d['reddito_residuo'])}\n'
              'Esito: ${d['ok'] == true ? 'SUSSISTENZA RISPETTATA' : 'SUSSISTENZA NON RISPETTATA'}',
            ),
          ),
        ),
      ],
    );
  }


  String _pct(dynamic value) {
    final n = value is num ? value.toDouble() : double.tryParse('$value');
    if (n == null) return '-';
    return '${n.toStringAsFixed(2)}%';
  }

  String _yesNo(bool ok) => ok ? 'RISPETTATO' : 'NON RISPETTATO';

  Widget _detailTile({
    required String title,
    required bool ok,
    required String body,
    String? subtitle,
  }) {
    return ExpansionTile(
      leading: _icon(ok),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SelectableText(body),
          ),
        ),
      ],
    );
  }

  Widget _allDetailsForBank(String banca) {
    final pack = verificationDetails[banca];
    if (pack == null) return const SizedBox.shrink();

    final prodotto = Map<String, dynamic>.from(pack['prodotto'] as Map? ?? {});
    final verifica = Map<String, dynamic>.from(pack['verifica'] as Map? ?? {});
    final pratica = ref.read(practiceProvider);
    final mortgage = pratica.mortgage;

    final richiedentiBody = pratica.richiedenti.asMap().entries.map((entry) {
      final i = entry.key + 1;
      final r = entry.value;
      return 'Richiedente $i: ${r.nome} ${r.cognome}\n'
          'Residenza: ${r.residenza}\n'
          'Area / Regione / Provincia: ${r.area.name} / ${r.regione} / ${r.provincia}\n'
          'Nazionalità: ${r.nazionalita}\n'
          'Reddito netto mensile: ${_eur(r.reddito)}\n'
          'Persone a carico: ${r.figli}';
    }).join('\n\n');

    final mutuoBody = mortgage == null
        ? 'Mutuo non compilato.'
        : 'Finalità: ${mortgage.finalita.name}\n'
          'Importo richiesto: ${_eur(mortgage.importoRichiesto)}\n'
          'Valore immobile: ${_eur(mortgage.valoreImmobile)}\n'
          'Durata: ${mortgage.durata} anni\n'
          'Classe energetica: ${mortgage.classeEnergetica}\n'
          'Tipo tasso: ${mortgage.tipoTasso.name}';

    final motiviProdotto = prodotto['motivi_esclusione'] is List
        ? (prodotto['motivi_esclusione'] as List).map((e) => e.toString()).join('\n• ')
        : '';
    final prodottoBody =
        'Prodotto considerato: ${prodotto['prodotto'] ?? '-'}\n'
        'Rata calcolata: ${_eur(prodotto['rata'])}\n'
        'Tasso finito: ${_pct(prodotto['tasso_finito'])}\n'
        'LTV pratica: ${_pct(prodotto['ltv'])}\n'
        'LTV massimo prodotto: ${prodotto['ltv_massimo'] ?? '-'}\n'
        'Semaforo prodotto: ${prodotto['semaforo'] ?? '-'}'
        '${motiviProdotto.isEmpty ? '' : '\nMotivi esclusione:\n• $motiviProdotto'}';

    final debiti = verifica['debiti'] is Map
        ? Map<String, dynamic>.from(verifica['debiti'])
        : <String, dynamic>{};
    final metodo = debiti['metodo']?.toString() ?? '-';
    final rapporto = debiti['rapporto_rata_reddito_percentuale'];
    String formulaDebiti = debiti['descrizione']?.toString() ?? '';
    if (metodo == 'RATA' && rapporto != null) {
      formulaDebiti += '\nCalcolo: ${_eur(debiti['reddito_totale'])} × ${_pct(rapporto)}'
          ' - ${_eur(debiti['rate_debiti'])}'
          ' = ${_eur(debiti['rata_massima_disponibile'])} capacità rata';
    } else if (metodo == 'REDDITO' && rapporto != null) {
      final redditoNetto = ((debiti['reddito_totale'] as num?)?.toDouble() ?? 0) -
          ((debiti['rate_debiti'] as num?)?.toDouble() ?? 0);
      formulaDebiti += '\nCalcolo: (${_eur(debiti['reddito_totale'])}'
          ' - ${_eur(debiti['rate_debiti'])})'
          ' = ${_eur(redditoNetto)} × ${_pct(rapporto)}'
          ' = ${_eur(debiti['rata_massima_disponibile'])} capacità rata';
    }
    final debitiBody =
        'Metodo banca: $metodo\n'
        'Reddito totale: ${_eur(debiti['reddito_totale'])}\n'
        'Rate debiti esistenti: ${_eur(debiti['rate_debiti'])}\n'
        'Rata nuovo mutuo: ${_eur(debiti['rata_mutuo'])}\n'
        'Capacità rata disponibile: ${_eur(debiti['rata_massima_disponibile'])}\n'
        'Margine: ${_eur(debiti['margine'])}\n'
        '$formulaDebiti\n'
        'Esito: ${_yesNo(debiti['ok'] == true)}';

    final eta = verifica['eta'] is Map
        ? Map<String, dynamic>.from(verifica['eta'])
        : <String, dynamic>{};
    final etaRows = eta['richiedenti'] is List ? eta['richiedenti'] as List : const [];
    final etaBody = [
      'Età massima banca a fine mutuo: ${eta['eta_massima_banca'] ?? '-'} anni',
      ...etaRows.map((row) {
        final m = Map<String, dynamic>.from(row as Map);
        return '${m['richiedente'] ?? 'Richiedente'}: '
            '${m['eta_attuale'] ?? '-'} anni oggi + ${mortgage?.durata ?? '-'} anni '
            '= ${m['eta_scadenza'] ?? '-'} anni a scadenza → ${_yesNo(m['ok'] == true)}';
      }),
      'Esito: ${_yesNo(eta['ok'] == true)}',
    ].join('\n');

    final anni = verifica['anni_italia'] is Map
        ? Map<String, dynamic>.from(verifica['anni_italia'])
        : <String, dynamic>{};
    final anniRows = anni['richiedenti'] is List ? anni['richiedenti'] as List : const [];
    final anniBody = [
      'Minimo banca per cittadino straniero: ${anni['minimo_banca'] ?? '-'} anni',
      ...anniRows.map((row) {
        final m = Map<String, dynamic>.from(row as Map);
        return '${m['richiedente'] ?? 'Richiedente'}: '
            'nazionalità ${m['nazionalita'] ?? '-'}, '
            'anni in Italia ${m['anni_italia'] ?? '-'} → ${_yesNo(m['ok'] == true)}';
      }),
      'Nota: per cittadino italiano il requisito è automaticamente soddisfatto.',
      'Esito: ${_yesNo(anni['ok'] == true)}',
    ].join('\n');

    final rr = verifica['rapporto_rata_reddito'] is Map
        ? Map<String, dynamic>.from(verifica['rapporto_rata_reddito'])
        : <String, dynamic>{};
    String rrFormula = rr['formula']?.toString() ?? '-';
    if (rr['metodo'] == 'RATA') {
      rrFormula += '\n${_eur(rr['reddito_totale'])} × ${_pct(rr['percentuale_banca'])}'
          ' - ${_eur(rr['rate_debiti'])}'
          ' = ${_eur(rr['capacita_rata'])}';
    } else if (rr['metodo'] == 'REDDITO') {
      rrFormula += '\n(${_eur(rr['reddito_totale'])} - ${_eur(rr['rate_debiti'])})'
          ' × ${_pct(rr['percentuale_banca'])}'
          ' = ${_eur(rr['capacita_rata'])}';
    }
    final rrBody =
        'Rapporto massimo banca: ${_pct(rr['percentuale_banca'])}\n'
        'Metodo: ${rr['metodo'] ?? '-'}\n'
        'Formula: $rrFormula\n'
        'Rata nuovo mutuo: ${_eur(rr['rata_mutuo'])}\n'
        'Capacità rata: ${_eur(rr['capacita_rata'])}\n'
        'Margine: ${_eur(rr['margine'])}\n'
        'Esito: ${_yesNo(rr['ok'] == true)}';

    final s = verifica['sussistenza'] is Map
        ? Map<String, dynamic>.from(verifica['sussistenza'])
        : <String, dynamic>{};
    final componenti = s['componenti_nucleo'];
    final oltre = s['numero_incrementi_oltre_5'] ?? 0;
    final incremento = s['incremento_oltre_5'];
    final soglia5 = s['soglia_base_5'];
    String sogliaFormula = 'Soglia applicata: ${_eur(s['soglia'])}';
    if (componenti is num && componenti > 5 && soglia5 != null && incremento != null) {
      sogliaFormula =
          '${_eur(soglia5)} + ($oltre × ${_eur(incremento)}) = ${_eur(s['soglia'])}';
    }
    final sussBody =
        'Tipo geografia: ${s['tipo_geografia'] ?? '-'}\n'
        'Geografia applicata: ${s['geografia'] ?? '-'}\n'
        'Richiedenti: ${s['numero_richiedenti'] ?? '-'}\n'
        'Persone a carico: ${s['persone_a_carico'] ?? '-'}\n'
        'Componenti nucleo: ${componenti ?? '-'}\n'
        'Soglia: $sogliaFormula\n'
        'Reddito totale: ${_eur(s['reddito_totale'])}\n'
        'Rate debiti: ${_eur(s['rate_debiti'])}\n'
        'Rata nuovo mutuo: ${_eur(s['rata_mutuo'])}\n'
        'Calcolo residuo: ${_eur(s['reddito_totale'])} - ${_eur(s['rate_debiti'])}'
        ' - ${_eur(s['rata_mutuo'])} = ${_eur(s['reddito_residuo'])}\n'
        'Esito: ${_yesNo(s['ok'] == true)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: _icon(_bankOk(banca)),
        title: Text('Dettaglio verifiche - $banca'),
        subtitle: Text(_bankOk(banca) ? 'Banca ammessa' : 'Banca esclusa'),
        children: [
          _detailTile(
            title: 'Richiedente',
            ok: checks[banca]?['Richiedente'] == true,
            body: richiedentiBody,
          ),
          _detailTile(
            title: 'Mutuo',
            ok: checks[banca]?['Mutuo'] == true,
            body: mutuoBody,
          ),
          _detailTile(
            title: 'Prodotto',
            ok: checks[banca]?['Prodotto'] == true,
            body: prodottoBody,
          ),
          _detailTile(
            title: 'Debiti',
            ok: checks[banca]?['Debiti'] == true,
            body: debitiBody,
          ),
          _detailTile(
            title: 'Età',
            ok: checks[banca]?['Età'] == true,
            body: etaBody,
          ),
          _detailTile(
            title: 'Anni in Italia',
            ok: checks[banca]?['Anni in Italia'] == true,
            body: anniBody,
          ),
          _detailTile(
            title: 'Rapporto rata/reddito',
            ok: checks[banca]?['Rapporto rata/reddito'] == true,
            body: rrBody,
          ),
          _detailTile(
            title: 'Sussistenza',
            ok: checks[banca]?['Sussistenza'] == true,
            body: sussBody,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final richiedentiOk = _globalRichiedentiOk();
    final mutuoOk = _globalMutuoOk();
    final almenoUnaBanca = banks.any(_bankOk);

    return Scaffold(
      appBar: AppBar(title: const Text('Verifica Pratica')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (!richiedentiOk)
              const Card(child: ListTile(leading: Icon(Icons.cancel, color: Colors.red), title: Text('Richiedente'), subtitle: Text('Nome e cognome sono obbligatori.'))),
            if (!mutuoOk)
              const Card(child: ListTile(leading: Icon(Icons.cancel, color: Colors.red), title: Text('Mutuo'), subtitle: Text('Compila i dati del mutuo.'))),
            if (loading) ...[
              const SizedBox(height: 80),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              const Center(child: Text('Verifico la pratica su tutte le banche caricate...')),
            ] else if (error != null) ...[
              Card(child: ListTile(leading: const Icon(Icons.error, color: Colors.red), title: const Text('Errore verifica'), subtitle: Text(error!))),
            ] else if (richiedentiOk && mutuoOk) ...[
              const Text('Confronto banca per banca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Una sola X rende la banca non ammessa. Nella schermata risultati saranno mostrate solo le banche che superano tutte le verifiche.'),
              const SizedBox(height: 12),
              _matrix(),
              const SizedBox(height: 12),
              ...banks
                  .where((b) => verificationDetails.containsKey(b))
                  .map(_allDetailsForBank),
              const SizedBox(height: 12),
              ...banks.where((b) => !_bankOk(b)).map(
                (b) => ExpansionTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: Text(b),
                  subtitle: const Text('Banca esclusa'),
                  children: [Padding(padding: const EdgeInsets.all(12), child: Align(alignment: Alignment.centerLeft, child: Text(notes[b] ?? '')))],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (!loading && error == null && richiedentiOk && mutuoOk && almenoUnaBanca)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultsPage(
                            response: _filteredResponse(),
                            pratica: ref.read(practiceProvider),
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text(almenoUnaBanca ? 'MOSTRA PRODOTTI AMMESSI' : 'NESSUNA BANCA AMMESSA'),
            ),
            if (!loading && richiedentiOk && mutuoOk && !almenoUnaBanca)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Tutte le banche hanno almeno una X: non è possibile accedere ai risultati.', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
