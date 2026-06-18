import 'package:intl/intl.dart';

class Problema {
  static const NOME_TABELA = 'problemas';
  static const CAMPO_ID = '_id';
  static const CAMPO_TIPO = 'tipo';
  static const CAMPO_DATA = 'data_reporte';
  static const CAMPO_RESOLVIDO = 'resolvido';

  int? id;
  String tipo;
  DateTime? dataReporte;
  bool resolvido;

  Problema({
    this.id,
    required this.tipo,
    this.dataReporte,
    this.resolvido = false
  });

  // Formata a data para mostrar na tela
  String get dataFormatada {
    if (dataReporte == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(dataReporte!);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_TIPO: tipo,
    CAMPO_DATA: dataReporte == null ? null : DateFormat("yyyy-MM-dd HH:mm:ss").format(dataReporte!),
    CAMPO_RESOLVIDO: resolvido ? 1 : 0,
  };

  factory Problema.fromMap(Map<String, dynamic> map) => Problema(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    tipo: map[CAMPO_TIPO] is String ? map[CAMPO_TIPO] : '',
    dataReporte: map[CAMPO_DATA] == null ? null :
    DateFormat("yyyy-MM-dd HH:mm:ss").parse(map[CAMPO_DATA]),
    resolvido: map[CAMPO_RESOLVIDO] == 1,
  );
}