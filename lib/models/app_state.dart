import 'package:flutter/material.dart';

// Modelo do Cidadão
class UsuarioCidadao {
  final String nome;
  final String email;
  final String endereco;
  final String telefone;

  UsuarioCidadao({
    required this.nome,
    required this.email,
    required this.endereco,
    required this.telefone,
  });
}

// Modelo do Motorista
class Motorista {
  final String nome;
  final String cpf;
  final String caminhao;
  final String senha;

  Motorista({
    required this.nome,
    required this.cpf,
    required this.caminhao,
    required this.senha,
  });
}

// Modelo de Rota unificado
class Rota {
  final String id;
  final String nome;
  final String ruas;
  final String horario;
  final DateTime? dataExata;
  final String motoristaNome;
  final String motoristaCpf;

  Rota({
    required this.id,
    required this.nome,
    required this.ruas,
    required this.horario,
    this.dataExata,
    required this.motoristaNome,
    required this.motoristaCpf,
  });
}

// Estado Global da Aplicação
UsuarioCidadao? usuarioLogadoGlobal;

// Guarda o motorista atualmente conectado no app
Motorista? motoristaLogadoGlobal;

// Lista de Rotas Globais acessível por todo o app
List<Rota> listaRotasGlobais = [
  Rota(
    id: 'rota_exemplo_1',
    nome: 'magano',
    ruas: 'Rua francisco branco',
    horario: '9/9 às 23:01',
    motoristaNome: 'Carlos Silva',
    motoristaCpf: '12345678900',
  )
];

// Lista de Motoristas Globais cadastrados
List<Motorista> listaMotoristasGlobais = [
  Motorista(
    nome: 'Carlos Silva',
    cpf: '12345678900',
    caminhao: 'Caminhão 01 - Voltz',
    senha: '123',
  ),
  Motorista(
    nome: 'João Santos',
    cpf: '98765432100',
    caminhao: 'Caminhão 02 - MB',
    senha: '123',
  ),
];

// Mapeamento auxiliar de dias
final Map<String, int> diasSemanaMap = {
  'dom': DateTime.sunday,
  'domingo': DateTime.sunday,
  'seg': DateTime.monday,
  'segunda': DateTime.monday,
  'ter': DateTime.tuesday,
  'terca': DateTime.tuesday,
  'terça': DateTime.tuesday,
  'qua': DateTime.wednesday,
  'quarta': DateTime.wednesday,
  'qui': DateTime.thursday,
  'quinta': DateTime.thursday,
  'sex': DateTime.friday,
  'sexta': DateTime.friday,
  'sab': DateTime.saturday,
  'sábado': DateTime.saturday,
  'sabado': DateTime.saturday,
};