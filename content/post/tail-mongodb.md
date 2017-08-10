---
title: "Tail Mongodb"
date: 2017-08-10:22:20-03:00
draft: true
---

A opcao de cursos tailable do mongodb, funciona parecido com o ```tail -f``` do linux, porem nao
podemos usar ela em qualquer colecao, a colecao precisa ter a opcao ```capped: true```, o que
significa que ela tera um tamanho maximo fixo, removendo documentos antigos para inserir novos.
Colecoes com essa opcao tem um high-throughput, o que e interessante para alguns projetos.

![alt text](http://content.tradyouth.org/uploads/2015/10/talk-is-cheap.jpg "Talk Is Cheat")

## Criando uma colection capped
```
db.createCollection("tail", {capped: true, size: 1})
```
Com esse comando criamos uma colecao capped, com tamanho de 1 byte, podemos tambem colocar a
opcao ```max``` que seta a quantidade maxima de documentos na colecao.

## In action
[![asciicast](https://asciinema.org/a/132761.png)](https://asciinema.org/a/132761)

```
cur = db.tail.find({}).addOption(DBQuery.Option.tailable).addOption(DBQuery.Option.awaitData)
```
Note que usei a funcao ```find``` normalmente, porem, adicionei duas opcoes ao cursor

* DBQuery.Option.tailable: quarante que o cursor nao ira fechar depois que receber os documentos;
* DBQuery.Option.awaitData: informa ao cursor para esperar o novo documento e ficar parado.

## oplog: It's kind of magic
Quando o servidor esta em um cluster ou eh iniciado com --master ele utiliza duas colecoes interessantes:

* local.oplog.$main: quando iniciado com  ```--master```
* local.oplog.rs: quando esta em cluster

[![asciicast](https://asciinema.org/a/132775.png)](https://asciinema.org/a/132775)


## Qual a utilidade?

* Atualizar outras colecoes
* Disparar requisicoes para outros sistemas
* Publisher/Subscriber
    * + Historico das mensagens
    * - Consumidor precisa manter o historico da ultima mensagem consumida
