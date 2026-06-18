// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cep.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cep _$CepFromJson(Map<String, dynamic> json) => Cep(
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      complemento: json['complemento'] as String?,
      unidade: json['unidade'] as String?,
      bairro: json['bairro'] as String?,
      localidade: json['localidade'] as String?,
      uf: json['uf'] as String?,
      estado: json['estado'] as String?,
      cidade: json['regiao'] as String?,
      ibge: json['ibge'] as String?,
      gia: json['gia'] as String?,
      ddd: json['ddd'] as String?,
      siafi: json['siafi'] as String?,
    );

Map<String, dynamic> _$CepToJson(Cep instance) => <String, dynamic>{
      'cep': instance.cep,
      'logradouro': instance.logradouro,
      'complemento': instance.complemento,
      'unidade': instance.unidade,
      'bairro': instance.bairro,
      'localidade': instance.localidade,
      'uf': instance.uf,
      'estado': instance.estado,
      'regiao': instance.cidade,
      'ibge': instance.ibge,
      'gia': instance.gia,
      'ddd': instance.ddd,
      'siafi': instance.siafi,
    };
