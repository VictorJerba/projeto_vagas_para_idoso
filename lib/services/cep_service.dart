import 'dart:convert';
import 'package:http/http.dart';
import '../model/cep.dart';

class CepService {
  static const _baseUrl = "https://viacep.com.br/ws/:cep/json/";

  Future<Map<String, dynamic>> findCep(String cep) async {
    final url = _baseUrl.replaceAll(':cep', cep);
    final uri = Uri.parse(url);
    final Response response = await get(uri);

    if(response.statusCode != 200 || response.body.isEmpty){
      throw Exception('Erro ao buscar o CEP');
    }

    final decodeBody = json.decode(response.body);

    // O ViaCEP retorna um JSON com { "erro": true } se o CEP for inválido
    if(decodeBody.containsKey('erro')) {
      throw Exception('CEP não encontrado');
    }

    return Map<String, dynamic>.from(decodeBody);
  }

  Future<Cep> findCepAsObject(String cep) async {
    final map = await findCep(cep);
    return Cep.fromJson(map);
  }
}