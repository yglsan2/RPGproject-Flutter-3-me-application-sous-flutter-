import 'dart:typed_data';
import 'package:flutter/material.dart' show Locale;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/character.dart';
import '../data/game_data.dart';
import '../l10n/app_localizations.dart';

/// Génère un PDF A4 de fiche personnage style INS/MV (ManyFaces).
class SheetPdfService {
  static const List<String> _defaultStatNames = [
    'Force', 'Agilité', 'Intelligence', 'Volonté', 'Perception', 'Présence',
  ];

  static String _tr(Locale locale, String key, [Map<String, String>? params]) =>
      AppLocalizations.trWithLocale(locale, key, params);

  /// Retourne les noms de caractéristiques pour le jeu/édition du personnage.
  static List<String> _statNamesFor(Character c) {
    final games = GameData.getGameSystems().where((g) => g.id == c.gameId).toList();
    if (games.isEmpty) return _defaultStatNames;
    final edition = games.first.getEdition(c.editionId);
    return edition?.statNames ?? _defaultStatNames;
  }

  /// Génère le PDF de la fiche (A4) et retourne les octets. [locale] sert aux libellés traduits.
  static Future<Uint8List> buildFichePdf(Character character, Locale locale) async {
    final pdf = pw.Document(
      title: _tr(locale, 'sheet_title_pdf', {'name': character.name}),
      author: 'ManyFaces',
      subject: '${_tr(locale, character.isNPC ? 'npc' : 'player')} – ${character.type}',
      keywords: 'INS/MV, ManyFaces, fiche, ${character.name}, ${character.superior}',
      creator: 'ManyFaces (DesertYGL)',
    );
    final statNames = _statNamesFor(character);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            _header(character, locale),
            pw.SizedBox(height: 16),
            _sectionTitle(_tr(locale, 'informations')),
            _block([
              _row(_tr(locale, 'name'), character.name, locale),
              _row(_tr(locale, 'type_label'), character.type, locale),
              _row(_tr(locale, 'superior'), character.superior, locale),
              _row(_tr(locale, 'role'), _tr(locale, character.isNPC ? 'npc' : 'player'), locale),
            ]),
            pw.SizedBox(height: 12),
            _sectionTitle(_tr(locale, 'resources')),
            _block([
              _row(_tr(locale, 'fatigue_points'), '${character.fatiguePoints}', locale),
              _row(_tr(locale, 'power_points'), '${character.powerPoints}', locale),
            ]),
            pw.SizedBox(height: 12),
            _sectionTitle(_tr(locale, 'characteristics')),
            _statsTable(character, statNames),
            if (character.motivation.trim().isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _sectionTitle(_tr(locale, 'motivation')),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, right: 8),
                child: pw.Text(
                  character.motivation,
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.left,
                ),
              ),
            ],
            pw.SizedBox(height: 12),
            _sectionTitle(_tr(locale, 'talents')),
            _listBlock(character.talents),
            pw.SizedBox(height: 12),
            _sectionTitle(_tr(locale, 'powers')),
            _powersBlock(character.powers, locale),
            if (character.competences.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _sectionTitle(_tr(locale, 'competences')),
              _competencesBlock(character.competences),
            ],
            if (character.equipment.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _sectionTitle(_tr(locale, 'equipment')),
              _listBlock(character.equipment),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _header(Character character, Locale locale) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 2, color: PdfColors.brown800),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _tr(locale, 'sheet_header').toUpperCase(),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.brown800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'ManyFaces – ${_formatDate(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.brown700,
        ),
      ),
    );
  }

  static pw.Widget _block(List<pw.Widget> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.brown300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  static pw.Widget _row(String label, String value, Locale locale) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _statsTable(Character character, List<String> statNames) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.brown300, width: 0.5),
      columnWidths: {
        for (var i = 0; i < statNames.length; i++) i: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.brown100),
          children: statNames
              .map((n) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      n,
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
        pw.TableRow(
          children: statNames
              .map((n) => pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      '${character.characteristics[n] ?? 0}',
                      style: const pw.TextStyle(fontSize: 11),
                      textAlign: pw.TextAlign.center,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  static pw.Widget _listBlock(List<String> items) {
    if (items.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          '—',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.brown300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Wrap(
        spacing: 4,
        runSpacing: 4,
        children: items
            .map((s) => pw.Container(
                  margin: const pw.EdgeInsets.only(right: 6, bottom: 4),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.brown50,
                    border: pw.Border.all(color: PdfColors.brown200),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(s, style: const pw.TextStyle(fontSize: 9)),
                ))
            .toList(),
      ),
    );
  }

  static pw.Widget _powersBlock(List<Power> powers, Locale locale) {
    if (powers.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          '—',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.brown300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(0.5),
          2: const pw.FlexColumnWidth(3),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.brown100),
            children: [
              _cell(_tr(locale, 'powers'), bold: true),
              _cell(_tr(locale, 'power_cost'), bold: true),
              _cell(_tr(locale, 'description'), bold: true),
            ],
          ),
          ...powers.map((p) => pw.TableRow(
                children: [
                  _cell(p.nameKey != null ? _tr(locale, p.nameKey!) : p.name),
                  _cell('${p.costPP}'),
                  _cell(p.descriptionKey != null ? _tr(locale, p.descriptionKey!) : (p.description.isNotEmpty ? p.description : '—')),
                ],
              )),
        ],
      ),
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _competencesBlock(Map<String, int> competences) {
    if (competences.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          '—',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      );
    }
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.brown300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Wrap(
        spacing: 4,
        runSpacing: 4,
        children: competences.entries
            .map((e) => pw.Container(
                  margin: const pw.EdgeInsets.only(right: 6, bottom: 4),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.brown50,
                    border: pw.Border.all(color: PdfColors.brown200),
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Text(
                    '${e.key} : ${e.value}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
