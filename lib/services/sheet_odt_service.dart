import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart' show Locale;
import '../models/character.dart';
import '../data/game_data.dart';
import '../l10n/app_localizations.dart';

/// Génère un fichier ODT (OpenDocument Text) de fiche personnage INS/MV, modifiable dans LibreOffice/Word.
class SheetOdtService {
  static const List<String> _defaultStatNames = [
    'Force', 'Agilité', 'Intelligence', 'Volonté', 'Perception', 'Présence',
  ];

  static String _tr(Locale locale, String key, [Map<String, String>? params]) =>
      AppLocalizations.trWithLocale(locale, key, params);

  static List<String> _statNamesFor(Character c) {
    final games = GameData.getGameSystems().where((g) => g.id == c.gameId).toList();
    if (games.isEmpty) return _defaultStatNames;
    final edition = games.first.getEdition(c.editionId);
    return edition?.statNames ?? _defaultStatNames;
  }

  static String _esc(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  /// Construit le XML content.xml du document.
  static String _buildContentXml(Character character, Locale locale) {
    final statNames = _statNamesFor(character);
    final sb = StringBuffer();
    sb.write('<?xml version="1.0" encoding="UTF-8"?>\n');
    sb.write('<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ');
    sb.write('xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" ');
    sb.write('xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" ');
    sb.write('xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" ');
    sb.write('xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0">\n');
    sb.write('<office:body><office:text>\n');

    sb.write('<text:h text:style-name="Heading_20_1">${_esc(_tr(locale, 'sheet_header').toUpperCase())}</text:h>\n');
    sb.write('<text:p text:style-name="Standard">ManyFaces – ${_formatDate(DateTime.now())}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"/>\n');

    sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'informations'))}</text:h>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'name'))} : </text:span>${_esc(character.name)}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'type_label'))} : </text:span>${_esc(character.type)}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'superior'))} : </text:span>${_esc(character.superior)}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'role'))} : </text:span>${_esc(_tr(locale, character.isNPC ? 'npc' : 'player'))}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"/>\n');

    sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'resources'))}</text:h>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'fatigue_points'))} : </text:span>${character.fatiguePoints}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"><text:span text:style-name="T1">${_esc(_tr(locale, 'power_points'))} : </text:span>${character.powerPoints}</text:p>\n');
    sb.write('<text:p text:style-name="Standard"/>\n');

    sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'characteristics'))}</text:h>\n');
    sb.write('<table:table table:name="Caracteristiques" table:style-name="Table1">\n');
    sb.write('<table:table-column table:style-name="Table1.A"/>');
    for (var i = 0; i < statNames.length - 1; i++) {
      sb.write('<table:table-column table:style-name="Table1.A"/>');
    }
    sb.write('\n<table:table-header-rows><table:table-row>\n');
    for (final n in statNames) {
      sb.write('<table:table-cell office:value-type="string"><text:p text:style-name="Table_20_Heading">${_esc(n)}</text:p></table:table-cell>\n');
    }
    sb.write('</table:table-row></table:table-header-rows>\n<table:table-row>\n');
    for (final n in statNames) {
      final v = character.characteristics[n] ?? 0;
      sb.write('<table:table-cell office:value-type="float" office:value="$v"><text:p text:style-name="Table_20_Contents">$v</text:p></table:table-cell>\n');
    }
    sb.write('</table:table-row>\n</table:table>\n');
    sb.write('<text:p text:style-name="Standard"/>\n');

    if (character.motivation.trim().isNotEmpty) {
      sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'motivation'))}</text:h>\n');
      sb.write('<text:p text:style-name="Standard">${_esc(character.motivation)}</text:p>\n');
      sb.write('<text:p text:style-name="Standard"/>\n');
    }

    sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'talents'))}</text:h>\n');
    if (character.talents.isEmpty) {
      sb.write('<text:p text:style-name="Standard">—</text:p>\n');
    } else {
      sb.write('<text:p text:style-name="Standard">${character.talents.map((t) => _esc(t)).join(', ')}</text:p>\n');
    }
    sb.write('<text:p text:style-name="Standard"/>\n');

    sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'powers'))}</text:h>\n');
    if (character.powers.isEmpty) {
      sb.write('<text:p text:style-name="Standard">—</text:p>\n');
    } else {
      sb.write('<table:table table:name="Pouvoirs" table:style-name="Table1">\n');
      sb.write('<table:table-column table:style-name="Table1.A"/><table:table-column table:style-name="Table1.A"/><table:table-column table:style-name="Table1.A"/>\n');
      sb.write('<table:table-header-rows><table:table-row>\n');
      sb.write('<table:table-cell><text:p text:style-name="Table_20_Heading">${_esc(_tr(locale, 'powers'))}</text:p></table:table-cell>\n');
      sb.write('<table:table-cell><text:p text:style-name="Table_20_Heading">${_esc(_tr(locale, 'power_cost'))}</text:p></table:table-cell>\n');
      sb.write('<table:table-cell><text:p text:style-name="Table_20_Heading">${_esc(_tr(locale, 'description'))}</text:p></table:table-cell>\n');
      sb.write('</table:table-row></table:table-header-rows>\n');
      for (final p in character.powers) {
        final pName = p.nameKey != null ? _tr(locale, p.nameKey!) : p.name;
        final pDesc = p.descriptionKey != null ? _tr(locale, p.descriptionKey!) : (p.description.isNotEmpty ? p.description : '—');
        sb.write('<table:table-row>\n');
        sb.write('<table:table-cell><text:p text:style-name="Table_20_Contents">${_esc(pName)}</text:p></table:table-cell>\n');
        sb.write('<table:table-cell><text:p text:style-name="Table_20_Contents">${p.costPP}</text:p></table:table-cell>\n');
        sb.write('<table:table-cell><text:p text:style-name="Table_20_Contents">${_esc(pDesc)}</text:p></table:table-cell>\n');
        sb.write('</table:table-row>\n');
      }
      sb.write('</table:table>\n');
    }
    sb.write('<text:p text:style-name="Standard"/>\n');

    if (character.competences.isNotEmpty) {
      sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'competences'))}</text:h>\n');
      sb.write('<text:p text:style-name="Standard">');
      sb.write(character.competences.entries.map((e) => '${_esc(e.key)} : ${e.value}').join(', '));
      sb.write('</text:p>\n<text:p text:style-name="Standard"/>\n');
    }

    if (character.equipment.isNotEmpty) {
      sb.write('<text:h text:style-name="Heading_20_2">${_esc(_tr(locale, 'equipment'))}</text:h>\n');
      sb.write('<text:p text:style-name="Standard">${character.equipment.map((e) => _esc(e)).join(', ')}</text:p>\n');
    }

    sb.write('</office:text></office:body></office:document-content>');
    return sb.toString();
  }

  static const String _stylesXml = '''<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0">
  <office:styles>
    <style:style style:name="Standard" style:family="paragraph"/>
    <style:style style:name="Heading_20_1" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-bottom="0.2in"/>
      <style:text-properties fo:font-size="16pt" fo:font-weight="bold"/>
    </style:style>
    <style:style style:name="Heading_20_2" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-top="0.1in" fo:margin-bottom="0.05in"/>
      <style:text-properties fo:font-size="12pt" fo:font-weight="bold"/>
    </style:style>
    <style:style style:name="T1" style:family="text">
      <style:text-properties fo:font-weight="bold"/>
    </style:style>
    <style:style style:name="Table1" style:family="table">
      <style:table-properties table:border-model="collapsing"/>
    </style:style>
    <style:style style:name="Table1.A" style:family="table-column"/>
    <style:style style:name="Table_20_Heading" style:family="paragraph" style:parent-style-name="Standard">
      <style:text-properties fo:font-weight="bold"/>
    </style:style>
    <style:style style:name="Table_20_Contents" style:family="paragraph" style:parent-style-name="Standard"/>
  </office:styles>
</office:document-styles>''';

  static String _metaXml(Character character, Locale locale) {
    final iso = DateTime.now().toUtc().toIso8601String();
    final roleLabel = character.isNPC ? _tr(locale, 'npc') : _tr(locale, 'player');
    return '''<?xml version="1.0" encoding="UTF-8"?>
<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0">
  <office:meta>
    <meta:creation-date>$iso</meta:creation-date>
    <dc:title>${_esc(character.name)} – ${_tr(locale, 'sheet_header')}</dc:title>
    <dc:creator>ManyFaces</dc:creator>
    <dc:description>${_tr(locale, 'sheet_header')} – $roleLabel – ${_esc(character.type)}, ${_esc(character.superior)}</dc:description>
  </office:meta>
</office:document-meta>''';
  }

  static const String _manifestXml = '''<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
  <manifest:file-entry manifest:full-path="/" manifest:media-type="application/vnd.oasis.opendocument.text"/>
  <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
  <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
  <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
</manifest:manifest>''';

  static const String _mimetype = 'application/vnd.oasis.opendocument.text';

  /// Génère le fichier ODT (octets). L'ordre des entrées dans le ZIP respecte l'ODF (mimetype en premier, non compressé).
  static Future<Uint8List> buildFicheOdt(Character character, Locale locale) async {
    final contentXml = _buildContentXml(character, locale);
    final metaXml = _metaXml(character, locale);

    final archive = Archive();
    final mimetypeBytes = Uint8List.fromList(utf8.encode(_mimetype));
    archive.addFile(ArchiveFile.noCompress('mimetype', mimetypeBytes.length, mimetypeBytes));
    archive.addFile(ArchiveFile('content.xml', utf8.encode(contentXml).length, utf8.encode(contentXml)));
    archive.addFile(ArchiveFile('styles.xml', utf8.encode(_stylesXml).length, utf8.encode(_stylesXml)));
    archive.addFile(ArchiveFile('meta.xml', utf8.encode(metaXml).length, utf8.encode(metaXml)));
    archive.addFile(ArchiveFile('META-INF/manifest.xml', utf8.encode(_manifestXml).length, utf8.encode(_manifestXml)));

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }
}
