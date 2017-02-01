# FGD (Forge Game Data) language support in Atom

Adds syntax highlighting and snippts for FGD (Forge Game Data) files in Atom.

![A GIF showing language-fgd in action](https://cloud.githubusercontent.com/assets/995050/22499748/cae8942c-e860-11e6-8630-39a860842cef.gif)

## Snippets

| Trigger       | Name                     | Body                 |
| ------------- |--------------------------| ---------------------|
| inc           | include file             | @include "file_name.fgd" |
| cls           | generic class            | @...Class base(ClassName, ...) = entity_name : "description" [ body... ] |
| bc            | base class               | @BaseClass ... |
| sc            | solid class              | @SolidClass ... |
| nc            | npc class                | @NPCClass ... |
| kc            | keyframe class           | @KeyFrameClass ... |
| mc            | move class               | @MoveClass ... |
| fc            | filter class             | @FilterClass ... |
| prop          | property                 | property_name(type) : "description" : default value |

## Install

```
$ apm install language-fgd
```

## Contribute

Anyone is welcome to contribute by creating [issues](issues) and [pull requests](pulls). This project follows the [Atom contributing guide](https://github.com/atom/atom/blob/master/CONTRIBUTING.md).

## License

MIT
