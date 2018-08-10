---
title: "Mongodb Watch"
date: 2018-08-10T13:52:44-03:00
tags: ["mongodb", "golang"]
---

Após 1 ano desde o minha publicação sobre a função [tail do mongodb](/post/tail-mongodb/), trago hoje como assunto a função watch.
A principal diferença entre estas duas funções é que o `tail` funciona somente para novos registro na `collection`
e necessita que ela seja `capped`(tamanho maximo fixo). Já a função `watch` não depende de nenhuma configuração para a
`collection` e funciona com operações como `inserts`, `update` e `delete`. No entanto o servidor tem que ser uma replicaset.

<!--more-->

Um bom exemplo da utilização desse recurso, seria salvar as configurações do sistema em uma `collection`. Com a função `watch`,
quando uma configuração for alterada ou adicionada o cursor será avisado, assim, o sistema pode ser atualizado diretamente.
Se o sistema estiver rodando em várias instancias, você não precisa se preocupar em avisar cada um deles, o mongodb fará isso
por você.

### Exemplo
Nesse exemplo escreverei uma aplicação em golang que terá um endpoint para mostra todas as configurações e a última ação de cada
configuração. Resultado esperado:

![result](/img/mongodb-watch/result.png)

![Talk is cheap, show me the code](/img/talk-is-cheap-show-me-the-code.jpg)

Para o exemplo funcionar precisamos que os documentos sigam esse modelo:
```json
{
    "_id": "config1",
    "value": "value1"
}
```
Primeiro vamos configurar as opções e o pipeline do `watch`, com um `timeout` de 10 segundos, e já iniciamos o `watch`.
```golang
pipe := []bson.M{}
options := mgo.ChangeStreamOptions{
    MaxAwaitTimeMS: time.Duration(10) * time.Second,
}
stream, err := coll.Watch(pipe, options)
if err != nil {
    panic(err)
}
```
Para este exemplo vamos utilizar somente esses campos do `watch`.
```golang
var result struct {
    OperationType     string                            `bson:"operationType"`
    FullDocument      map[string]string                 `bson:"fullDocument"`
    DocumentKey       map[string]string                 `bson:"documentKey"`
    UpdateDescription map[string]map[string]interface{} `bson:"updateDescription"`
}
```
Iniciamos um loop enquanto a função `stream.Next(&result)`, recebe um pointeiro para uma interface onde estará as informações. Quando retorna `false`
pode ser um erro(`stream.Err()` returna um `error`) ou um timeout(`stream.Timeout()` returna `true`).
```golang
for {
    for stream.Next(&result) {
        conf := Config{
            Name: result.DocumentKey["_id"],
            Op:   result.OperationType,
        }
        if v, ok := result.FullDocument["value"]; ok {
            conf.Value = v
        }
        if v, ok := result.UpdateDescription["updatedFields"]["value"]; ok {
            conf.Value = v
        }
        configs[conf.Name] = conf
    }
    if err := stream.Err(); err != nil {
        panic(err)
    }
}
```

#### Código completo
<script src="https://gist.github.com/darkSasori/0f644858e4dc5fc4a67e98ae9c607f1b.js"></script>

#### Referências
 - [db.collection.watch](https://docs.mongodb.com/manual/reference/method/db.collection.watch/)
 - [db.watch](https://docs.mongodb.com/manual/reference/method/db.watch)
 - [Mongo.watch](https://docs.mongodb.com/manual/reference/method/Mongo.watch)
