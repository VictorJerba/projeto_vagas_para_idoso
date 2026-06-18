import '../database/database_provider.dart';
import '../model/problema.dart';

class ProblemaDao {
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(Problema problema) async {
    final db = await dbProvider.database;
    final valores = problema.toMap();

    if (problema.id == null) {
      problema.id = await db.insert(Problema.NOME_TABELA, valores);
      return true;
    } else {
      final registrosAtualizados = await db.update(
          Problema.NOME_TABELA, valores,
          where: '${Problema.CAMPO_ID} = ?', whereArgs: [problema.id]
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> excluir(int id) async {
    final db = await dbProvider.database;
    final registrosAtualizados = await db.delete(Problema.NOME_TABELA,
        where: '${Problema.CAMPO_ID} = ?', whereArgs: [id]);

    return registrosAtualizados > 0;
  }

  Future<List<Problema>> listar({
    String filtro = '',
    String campoOrdenacao = Problema.CAMPO_ID,
    bool usarOrdemDecrescente = true // true pra mostrar o mais recente primeiro
  }) async {
    String? where;
    if (filtro.isNotEmpty) {
      // LIKE para pesquisar problemas
      where = "UPPER(${Problema.CAMPO_TIPO}) LIKE '${filtro.toUpperCase()}%'";
    }

    var orderBy = campoOrdenacao;

    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }

    final db = await dbProvider.database;
    final resultado = await db.query(Problema.NOME_TABELA,
        columns: [
          Problema.CAMPO_ID,
          Problema.CAMPO_TIPO,
          Problema.CAMPO_DATA,
          Problema.CAMPO_RESOLVIDO
        ],
        where: where,
        orderBy: orderBy
    );

    return resultado.map((m) => Problema.fromMap(m)).toList();
  }
}