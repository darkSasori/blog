---
title: "Tail Mongodb"
date: 2017-08-10T23:22:20-03:00
tags: ["mongodb", "golang"]
---

A opção de cursos tailable do mongodb, funciona parecido com o ```tail -f``` do linux, porém não
podemos usar ela em qualquer coleção, a coleção precisa ter a opção ```capped: true```, o que
significa que ela terá um tamanho máximo fixo, removendo documentos antigos para inserir novos.

<!--more-->

## Criando uma colection capped

``` db.createCollection("tail", {capped: true, size: 1}) ```

Com esse comando criamos uma coleção capped, com tamanho de 1 byte, podemos também colocar a
opção ```max``` que seta a quantidade máxima de documentos na coleção.

## In action
[![asciicast](https://asciinema.org/a/132761.png)](https://asciinema.org/a/132761)

``` cur = db.tail.find({}).addOption(DBQuery.Option.tailable).addOption(DBQuery.Option.awaitData) ```
Note que usei a função ```find``` normalmente, porém, adicionei duas opções ao cursor

* DBQuery.Option.tailable: quarante que o cursor não ira fechar depois que receber os documentos;
* DBQuery.Option.awaitData: informa ao cursor para esperar o novo documento e ficar parado.

## oplog: It's kind of magic
Quando o servidor esta em um cluster ou é iniciado com ```--master``` ele utiliza duas coleções interessantes:

* local.oplog.$main: quando iniciado com  ```--master```
* local.oplog.rs: quando esta em cluster

[![asciicast](https://asciinema.org/a/132775.png)](https://asciinema.org/a/132775)

## Chat

Pequeno chat que demostra como podemos utilizar essa opção do mongodb.

<script src="https://gist.github.com/darkSasori/c4918f4d5d84464ce4438df5cf641200.js"></script>
