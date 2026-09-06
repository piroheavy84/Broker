from pathlib import Path


PATH = Path("lib/pages/practice/results_page.dart")
text = PATH.read_text(encoding="utf-8")

old_note = '''              if (r["motivo_prodotto_speciale"] != null)
                Text("Nota: ${r["motivo_prodotto_speciale"]}"),
'''
new_note = '''              if (r["motivo_prodotto_speciale"] != null &&
                  !(r["sconti_applicati"] is List &&
                      (r["sconti_applicati"] as List).isNotEmpty))
                Text("Nota: ${r["motivo_prodotto_speciale"]}"),
'''
if old_note not in text:
    raise SystemExit("Anchor nota prodotto speciale non trovato")
text = text.replace(old_note, new_note, 1)

old_spread = '''            Text(
              "Spread: ${(r["spread"] as num).toStringAsFixed(2)}%",
            ),
            if (r["prodotto_speciale"] == true && r["spread_base"] != null)
              Text("Spread base: ${r["spread_base"]}"),
            if (r["prodotto_speciale"] == true && r["spread_delta"] is num)
              Text(
                (r["spread_delta"] as num) < 0
                    ? "Sconto: ${(r["spread_delta"] as num).toStringAsFixed(2)}%"
                    : "Maggiorazione: +${(r["spread_delta"] as num).toStringAsFixed(2)}%",
              ),
'''

new_spread = '''            if (r["sconti_applicati"] is List &&
                (r["sconti_applicati"] as List).isNotEmpty) ...[
              Text(
                "Spread base: ${((r["spread_base_commerciale"] ?? r["spread_base"] ?? r["spread"]) as num).toStringAsFixed(2)}%",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              for (final rawSconto in r["sconti_applicati"] as List)
                if (rawSconto is Map)
                  Text(
                    "${rawSconto["label"] ?? "Sconto"}: -${((rawSconto["percentuale"] ?? 0) as num).toStringAsFixed(2)}%",
                  ),
              const SizedBox(height: 3),
              Text(
                "Sconto totale: -${((r["sconto_totale_percentuale"] ?? 0) as num).toStringAsFixed(2)}%",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                "Nuovo spread: ${(r["spread"] as num).toStringAsFixed(2)}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (r["reddito_residuo_sconti"] is num)
                Text(
                  "Residuo reddituale per sconto MRI: € ${(r["reddito_residuo_sconti"] as num).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 12),
                ),
            ] else ...[
              Text(
                "Spread: ${(r["spread"] as num).toStringAsFixed(2)}%",
              ),
              if (r["prodotto_speciale"] == true && r["spread_base"] != null)
                Text("Spread base: ${r["spread_base"]}"),
              if (r["prodotto_speciale"] == true && r["spread_delta"] is num)
                Text(
                  (r["spread_delta"] as num) < 0
                      ? "Sconto: ${(r["spread_delta"] as num).toStringAsFixed(2)}%"
                      : "Maggiorazione: +${(r["spread_delta"] as num).toStringAsFixed(2)}%",
                ),
            ],
'''

if old_spread not in text:
    raise SystemExit("Anchor spread risultati non trovato")
text = text.replace(old_spread, new_spread, 1)

PATH.write_text(text, encoding="utf-8")
print("results_page.dart aggiornato con dettaglio scontistiche")
