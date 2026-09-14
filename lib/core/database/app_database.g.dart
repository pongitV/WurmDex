// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorTagMeta = const VerificationMeta(
    'colorTag',
  );
  @override
  late final GeneratedColumn<String> colorTag = GeneratedColumn<String>(
    'color_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#7C3AED'),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _displayModeMeta = const VerificationMeta(
    'displayMode',
  );
  @override
  late final GeneratedColumn<String> displayMode = GeneratedColumn<String>(
    'display_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('grid'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    colorTag,
    iconName,
    displayMode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color_tag')) {
      context.handle(
        _colorTagMeta,
        colorTag.isAcceptableOrUnknown(data['color_tag']!, _colorTagMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('display_mode')) {
      context.handle(
        _displayModeMeta,
        displayMode.isAcceptableOrUnknown(
          data['display_mode']!,
          _displayModeMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      colorTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_tag'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      displayMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_mode'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String id;
  final String name;
  final String description;
  final String colorTag;
  final String iconName;
  final String displayMode;
  final DateTime createdAt;
  const Folder({
    required this.id,
    required this.name,
    required this.description,
    required this.colorTag,
    required this.iconName,
    required this.displayMode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['color_tag'] = Variable<String>(colorTag);
    map['icon_name'] = Variable<String>(iconName);
    map['display_mode'] = Variable<String>(displayMode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      colorTag: Value(colorTag),
      iconName: Value(iconName),
      displayMode: Value(displayMode),
      createdAt: Value(createdAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      colorTag: serializer.fromJson<String>(json['colorTag']),
      iconName: serializer.fromJson<String>(json['iconName']),
      displayMode: serializer.fromJson<String>(json['displayMode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'colorTag': serializer.toJson<String>(colorTag),
      'iconName': serializer.toJson<String>(iconName),
      'displayMode': serializer.toJson<String>(displayMode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Folder copyWith({
    String? id,
    String? name,
    String? description,
    String? colorTag,
    String? iconName,
    String? displayMode,
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    colorTag: colorTag ?? this.colorTag,
    iconName: iconName ?? this.iconName,
    displayMode: displayMode ?? this.displayMode,
    createdAt: createdAt ?? this.createdAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      colorTag: data.colorTag.present ? data.colorTag.value : this.colorTag,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      displayMode: data.displayMode.present
          ? data.displayMode.value
          : this.displayMode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorTag: $colorTag, ')
          ..write('iconName: $iconName, ')
          ..write('displayMode: $displayMode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    colorTag,
    iconName,
    displayMode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.colorTag == this.colorTag &&
          other.iconName == this.iconName &&
          other.displayMode == this.displayMode &&
          other.createdAt == this.createdAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> colorTag;
  final Value<String> iconName;
  final Value<String> displayMode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.iconName = const Value.absent(),
    this.displayMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.colorTag = const Value.absent(),
    this.iconName = const Value.absent(),
    this.displayMode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Folder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? colorTag,
    Expression<String>? iconName,
    Expression<String>? displayMode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (colorTag != null) 'color_tag': colorTag,
      if (iconName != null) 'icon_name': iconName,
      if (displayMode != null) 'display_mode': displayMode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? colorTag,
    Value<String>? iconName,
    Value<String>? displayMode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorTag: colorTag ?? this.colorTag,
      iconName: iconName ?? this.iconName,
      displayMode: displayMode ?? this.displayMode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (colorTag.present) {
      map['color_tag'] = Variable<String>(colorTag.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (displayMode.present) {
      map['display_mode'] = Variable<String>(displayMode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorTag: $colorTag, ')
          ..write('iconName: $iconName, ')
          ..write('displayMode: $displayMode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCardsTable extends UserCards
    with TableInfo<$UserCardsTable, UserCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardApiIdMeta = const VerificationMeta(
    'cardApiId',
  );
  @override
  late final GeneratedColumn<String> cardApiId = GeneratedColumn<String>(
    'card_api_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Near Mint'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PT'),
  );
  static const VerificationMeta _finishMeta = const VerificationMeta('finish');
  @override
  late final GeneratedColumn<String> finish = GeneratedColumn<String>(
    'finish',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Regular'),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _purchasePriceBrlMeta = const VerificationMeta(
    'purchasePriceBrl',
  );
  @override
  late final GeneratedColumn<double> purchasePriceBrl = GeneratedColumn<double>(
    'purchase_price_brl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardApiId,
    name,
    number,
    setName,
    rarity,
    imageUrl,
    folderId,
    condition,
    language,
    finish,
    quantity,
    purchasePriceBrl,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_api_id')) {
      context.handle(
        _cardApiIdMeta,
        cardApiId.isAcceptableOrUnknown(data['card_api_id']!, _cardApiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardApiIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('finish')) {
      context.handle(
        _finishMeta,
        finish.isAcceptableOrUnknown(data['finish']!, _finishMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('purchase_price_brl')) {
      context.handle(
        _purchasePriceBrlMeta,
        purchasePriceBrl.isAcceptableOrUnknown(
          data['purchase_price_brl']!,
          _purchasePriceBrlMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_api_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      finish: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finish'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      purchasePriceBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price_brl'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserCardsTable createAlias(String alias) {
    return $UserCardsTable(attachedDatabase, alias);
  }
}

class UserCard extends DataClass implements Insertable<UserCard> {
  final String id;
  final String cardApiId;
  final String name;
  final String number;
  final String setName;
  final String rarity;
  final String imageUrl;
  final String? folderId;
  final String condition;
  final String language;
  final String finish;
  final int quantity;
  final double purchasePriceBrl;
  final DateTime createdAt;
  const UserCard({
    required this.id,
    required this.cardApiId,
    required this.name,
    required this.number,
    required this.setName,
    required this.rarity,
    required this.imageUrl,
    this.folderId,
    required this.condition,
    required this.language,
    required this.finish,
    required this.quantity,
    required this.purchasePriceBrl,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_api_id'] = Variable<String>(cardApiId);
    map['name'] = Variable<String>(name);
    map['number'] = Variable<String>(number);
    map['set_name'] = Variable<String>(setName);
    map['rarity'] = Variable<String>(rarity);
    map['image_url'] = Variable<String>(imageUrl);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['condition'] = Variable<String>(condition);
    map['language'] = Variable<String>(language);
    map['finish'] = Variable<String>(finish);
    map['quantity'] = Variable<int>(quantity);
    map['purchase_price_brl'] = Variable<double>(purchasePriceBrl);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserCardsCompanion toCompanion(bool nullToAbsent) {
    return UserCardsCompanion(
      id: Value(id),
      cardApiId: Value(cardApiId),
      name: Value(name),
      number: Value(number),
      setName: Value(setName),
      rarity: Value(rarity),
      imageUrl: Value(imageUrl),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      condition: Value(condition),
      language: Value(language),
      finish: Value(finish),
      quantity: Value(quantity),
      purchasePriceBrl: Value(purchasePriceBrl),
      createdAt: Value(createdAt),
    );
  }

  factory UserCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCard(
      id: serializer.fromJson<String>(json['id']),
      cardApiId: serializer.fromJson<String>(json['cardApiId']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<String>(json['number']),
      setName: serializer.fromJson<String>(json['setName']),
      rarity: serializer.fromJson<String>(json['rarity']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      condition: serializer.fromJson<String>(json['condition']),
      language: serializer.fromJson<String>(json['language']),
      finish: serializer.fromJson<String>(json['finish']),
      quantity: serializer.fromJson<int>(json['quantity']),
      purchasePriceBrl: serializer.fromJson<double>(json['purchasePriceBrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardApiId': serializer.toJson<String>(cardApiId),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<String>(number),
      'setName': serializer.toJson<String>(setName),
      'rarity': serializer.toJson<String>(rarity),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'folderId': serializer.toJson<String?>(folderId),
      'condition': serializer.toJson<String>(condition),
      'language': serializer.toJson<String>(language),
      'finish': serializer.toJson<String>(finish),
      'quantity': serializer.toJson<int>(quantity),
      'purchasePriceBrl': serializer.toJson<double>(purchasePriceBrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserCard copyWith({
    String? id,
    String? cardApiId,
    String? name,
    String? number,
    String? setName,
    String? rarity,
    String? imageUrl,
    Value<String?> folderId = const Value.absent(),
    String? condition,
    String? language,
    String? finish,
    int? quantity,
    double? purchasePriceBrl,
    DateTime? createdAt,
  }) => UserCard(
    id: id ?? this.id,
    cardApiId: cardApiId ?? this.cardApiId,
    name: name ?? this.name,
    number: number ?? this.number,
    setName: setName ?? this.setName,
    rarity: rarity ?? this.rarity,
    imageUrl: imageUrl ?? this.imageUrl,
    folderId: folderId.present ? folderId.value : this.folderId,
    condition: condition ?? this.condition,
    language: language ?? this.language,
    finish: finish ?? this.finish,
    quantity: quantity ?? this.quantity,
    purchasePriceBrl: purchasePriceBrl ?? this.purchasePriceBrl,
    createdAt: createdAt ?? this.createdAt,
  );
  UserCard copyWithCompanion(UserCardsCompanion data) {
    return UserCard(
      id: data.id.present ? data.id.value : this.id,
      cardApiId: data.cardApiId.present ? data.cardApiId.value : this.cardApiId,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      setName: data.setName.present ? data.setName.value : this.setName,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      condition: data.condition.present ? data.condition.value : this.condition,
      language: data.language.present ? data.language.value : this.language,
      finish: data.finish.present ? data.finish.value : this.finish,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      purchasePriceBrl: data.purchasePriceBrl.present
          ? data.purchasePriceBrl.value
          : this.purchasePriceBrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCard(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('setName: $setName, ')
          ..write('rarity: $rarity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('folderId: $folderId, ')
          ..write('condition: $condition, ')
          ..write('language: $language, ')
          ..write('finish: $finish, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePriceBrl: $purchasePriceBrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardApiId,
    name,
    number,
    setName,
    rarity,
    imageUrl,
    folderId,
    condition,
    language,
    finish,
    quantity,
    purchasePriceBrl,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCard &&
          other.id == this.id &&
          other.cardApiId == this.cardApiId &&
          other.name == this.name &&
          other.number == this.number &&
          other.setName == this.setName &&
          other.rarity == this.rarity &&
          other.imageUrl == this.imageUrl &&
          other.folderId == this.folderId &&
          other.condition == this.condition &&
          other.language == this.language &&
          other.finish == this.finish &&
          other.quantity == this.quantity &&
          other.purchasePriceBrl == this.purchasePriceBrl &&
          other.createdAt == this.createdAt);
}

class UserCardsCompanion extends UpdateCompanion<UserCard> {
  final Value<String> id;
  final Value<String> cardApiId;
  final Value<String> name;
  final Value<String> number;
  final Value<String> setName;
  final Value<String> rarity;
  final Value<String> imageUrl;
  final Value<String?> folderId;
  final Value<String> condition;
  final Value<String> language;
  final Value<String> finish;
  final Value<int> quantity;
  final Value<double> purchasePriceBrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserCardsCompanion({
    this.id = const Value.absent(),
    this.cardApiId = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.setName = const Value.absent(),
    this.rarity = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.folderId = const Value.absent(),
    this.condition = const Value.absent(),
    this.language = const Value.absent(),
    this.finish = const Value.absent(),
    this.quantity = const Value.absent(),
    this.purchasePriceBrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCardsCompanion.insert({
    required String id,
    required String cardApiId,
    required String name,
    this.number = const Value.absent(),
    this.setName = const Value.absent(),
    this.rarity = const Value.absent(),
    required String imageUrl,
    this.folderId = const Value.absent(),
    this.condition = const Value.absent(),
    this.language = const Value.absent(),
    this.finish = const Value.absent(),
    this.quantity = const Value.absent(),
    this.purchasePriceBrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardApiId = Value(cardApiId),
       name = Value(name),
       imageUrl = Value(imageUrl);
  static Insertable<UserCard> custom({
    Expression<String>? id,
    Expression<String>? cardApiId,
    Expression<String>? name,
    Expression<String>? number,
    Expression<String>? setName,
    Expression<String>? rarity,
    Expression<String>? imageUrl,
    Expression<String>? folderId,
    Expression<String>? condition,
    Expression<String>? language,
    Expression<String>? finish,
    Expression<int>? quantity,
    Expression<double>? purchasePriceBrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardApiId != null) 'card_api_id': cardApiId,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (setName != null) 'set_name': setName,
      if (rarity != null) 'rarity': rarity,
      if (imageUrl != null) 'image_url': imageUrl,
      if (folderId != null) 'folder_id': folderId,
      if (condition != null) 'condition': condition,
      if (language != null) 'language': language,
      if (finish != null) 'finish': finish,
      if (quantity != null) 'quantity': quantity,
      if (purchasePriceBrl != null) 'purchase_price_brl': purchasePriceBrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardApiId,
    Value<String>? name,
    Value<String>? number,
    Value<String>? setName,
    Value<String>? rarity,
    Value<String>? imageUrl,
    Value<String?>? folderId,
    Value<String>? condition,
    Value<String>? language,
    Value<String>? finish,
    Value<int>? quantity,
    Value<double>? purchasePriceBrl,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserCardsCompanion(
      id: id ?? this.id,
      cardApiId: cardApiId ?? this.cardApiId,
      name: name ?? this.name,
      number: number ?? this.number,
      setName: setName ?? this.setName,
      rarity: rarity ?? this.rarity,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId ?? this.folderId,
      condition: condition ?? this.condition,
      language: language ?? this.language,
      finish: finish ?? this.finish,
      quantity: quantity ?? this.quantity,
      purchasePriceBrl: purchasePriceBrl ?? this.purchasePriceBrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardApiId.present) {
      map['card_api_id'] = Variable<String>(cardApiId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (finish.present) {
      map['finish'] = Variable<String>(finish.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (purchasePriceBrl.present) {
      map['purchase_price_brl'] = Variable<double>(purchasePriceBrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCardsCompanion(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('setName: $setName, ')
          ..write('rarity: $rarity, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('folderId: $folderId, ')
          ..write('condition: $condition, ')
          ..write('language: $language, ')
          ..write('finish: $finish, ')
          ..write('quantity: $quantity, ')
          ..write('purchasePriceBrl: $purchasePriceBrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsTable extends WishlistItems
    with TableInfo<$WishlistItemsTable, WishlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardApiIdMeta = const VerificationMeta(
    'cardApiId',
  );
  @override
  late final GeneratedColumn<String> cardApiId = GeneratedColumn<String>(
    'card_api_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPriceBrlMeta = const VerificationMeta(
    'targetPriceBrl',
  );
  @override
  late final GeneratedColumn<double> targetPriceBrl = GeneratedColumn<double>(
    'target_price_brl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _minTargetPriceBrlMeta = const VerificationMeta(
    'minTargetPriceBrl',
  );
  @override
  late final GeneratedColumn<double> minTargetPriceBrl =
      GeneratedColumn<double>(
        'min_target_price_brl',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Near Mint'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Média'),
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Geral'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PT'),
  );
  static const VerificationMeta _isPreSaleMeta = const VerificationMeta(
    'isPreSale',
  );
  @override
  late final GeneratedColumn<bool> isPreSale = GeneratedColumn<bool>(
    'is_pre_sale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pre_sale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentPriceBrlMeta = const VerificationMeta(
    'currentPriceBrl',
  );
  @override
  late final GeneratedColumn<double> currentPriceBrl = GeneratedColumn<double>(
    'current_price_brl',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardApiId,
    name,
    number,
    setName,
    imageUrl,
    targetPriceBrl,
    minTargetPriceBrl,
    condition,
    priority,
    folderName,
    language,
    isPreSale,
    currentPriceBrl,
    lastCheckedAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_api_id')) {
      context.handle(
        _cardApiIdMeta,
        cardApiId.isAcceptableOrUnknown(data['card_api_id']!, _cardApiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardApiIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('target_price_brl')) {
      context.handle(
        _targetPriceBrlMeta,
        targetPriceBrl.isAcceptableOrUnknown(
          data['target_price_brl']!,
          _targetPriceBrlMeta,
        ),
      );
    }
    if (data.containsKey('min_target_price_brl')) {
      context.handle(
        _minTargetPriceBrlMeta,
        minTargetPriceBrl.isAcceptableOrUnknown(
          data['min_target_price_brl']!,
          _minTargetPriceBrlMeta,
        ),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('is_pre_sale')) {
      context.handle(
        _isPreSaleMeta,
        isPreSale.isAcceptableOrUnknown(data['is_pre_sale']!, _isPreSaleMeta),
      );
    }
    if (data.containsKey('current_price_brl')) {
      context.handle(
        _currentPriceBrlMeta,
        currentPriceBrl.isAcceptableOrUnknown(
          data['current_price_brl']!,
          _currentPriceBrlMeta,
        ),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_api_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      targetPriceBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_price_brl'],
      )!,
      minTargetPriceBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_target_price_brl'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      isPreSale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pre_sale'],
      )!,
      currentPriceBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_price_brl'],
      ),
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WishlistItemsTable createAlias(String alias) {
    return $WishlistItemsTable(attachedDatabase, alias);
  }
}

class WishlistItem extends DataClass implements Insertable<WishlistItem> {
  final String id;
  final String cardApiId;
  final String name;
  final String number;
  final String setName;
  final String imageUrl;
  final double targetPriceBrl;
  final double minTargetPriceBrl;
  final String condition;
  final String priority;
  final String folderName;
  final String language;
  final bool isPreSale;
  final double? currentPriceBrl;
  final DateTime? lastCheckedAt;
  final String notes;
  final DateTime createdAt;
  const WishlistItem({
    required this.id,
    required this.cardApiId,
    required this.name,
    required this.number,
    required this.setName,
    required this.imageUrl,
    required this.targetPriceBrl,
    required this.minTargetPriceBrl,
    required this.condition,
    required this.priority,
    required this.folderName,
    required this.language,
    required this.isPreSale,
    this.currentPriceBrl,
    this.lastCheckedAt,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_api_id'] = Variable<String>(cardApiId);
    map['name'] = Variable<String>(name);
    map['number'] = Variable<String>(number);
    map['set_name'] = Variable<String>(setName);
    map['image_url'] = Variable<String>(imageUrl);
    map['target_price_brl'] = Variable<double>(targetPriceBrl);
    map['min_target_price_brl'] = Variable<double>(minTargetPriceBrl);
    map['condition'] = Variable<String>(condition);
    map['priority'] = Variable<String>(priority);
    map['folder_name'] = Variable<String>(folderName);
    map['language'] = Variable<String>(language);
    map['is_pre_sale'] = Variable<bool>(isPreSale);
    if (!nullToAbsent || currentPriceBrl != null) {
      map['current_price_brl'] = Variable<double>(currentPriceBrl);
    }
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WishlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCompanion(
      id: Value(id),
      cardApiId: Value(cardApiId),
      name: Value(name),
      number: Value(number),
      setName: Value(setName),
      imageUrl: Value(imageUrl),
      targetPriceBrl: Value(targetPriceBrl),
      minTargetPriceBrl: Value(minTargetPriceBrl),
      condition: Value(condition),
      priority: Value(priority),
      folderName: Value(folderName),
      language: Value(language),
      isPreSale: Value(isPreSale),
      currentPriceBrl: currentPriceBrl == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPriceBrl),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory WishlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItem(
      id: serializer.fromJson<String>(json['id']),
      cardApiId: serializer.fromJson<String>(json['cardApiId']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<String>(json['number']),
      setName: serializer.fromJson<String>(json['setName']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      targetPriceBrl: serializer.fromJson<double>(json['targetPriceBrl']),
      minTargetPriceBrl: serializer.fromJson<double>(json['minTargetPriceBrl']),
      condition: serializer.fromJson<String>(json['condition']),
      priority: serializer.fromJson<String>(json['priority']),
      folderName: serializer.fromJson<String>(json['folderName']),
      language: serializer.fromJson<String>(json['language']),
      isPreSale: serializer.fromJson<bool>(json['isPreSale']),
      currentPriceBrl: serializer.fromJson<double?>(json['currentPriceBrl']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardApiId': serializer.toJson<String>(cardApiId),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<String>(number),
      'setName': serializer.toJson<String>(setName),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'targetPriceBrl': serializer.toJson<double>(targetPriceBrl),
      'minTargetPriceBrl': serializer.toJson<double>(minTargetPriceBrl),
      'condition': serializer.toJson<String>(condition),
      'priority': serializer.toJson<String>(priority),
      'folderName': serializer.toJson<String>(folderName),
      'language': serializer.toJson<String>(language),
      'isPreSale': serializer.toJson<bool>(isPreSale),
      'currentPriceBrl': serializer.toJson<double?>(currentPriceBrl),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WishlistItem copyWith({
    String? id,
    String? cardApiId,
    String? name,
    String? number,
    String? setName,
    String? imageUrl,
    double? targetPriceBrl,
    double? minTargetPriceBrl,
    String? condition,
    String? priority,
    String? folderName,
    String? language,
    bool? isPreSale,
    Value<double?> currentPriceBrl = const Value.absent(),
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    String? notes,
    DateTime? createdAt,
  }) => WishlistItem(
    id: id ?? this.id,
    cardApiId: cardApiId ?? this.cardApiId,
    name: name ?? this.name,
    number: number ?? this.number,
    setName: setName ?? this.setName,
    imageUrl: imageUrl ?? this.imageUrl,
    targetPriceBrl: targetPriceBrl ?? this.targetPriceBrl,
    minTargetPriceBrl: minTargetPriceBrl ?? this.minTargetPriceBrl,
    condition: condition ?? this.condition,
    priority: priority ?? this.priority,
    folderName: folderName ?? this.folderName,
    language: language ?? this.language,
    isPreSale: isPreSale ?? this.isPreSale,
    currentPriceBrl: currentPriceBrl.present
        ? currentPriceBrl.value
        : this.currentPriceBrl,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  WishlistItem copyWithCompanion(WishlistItemsCompanion data) {
    return WishlistItem(
      id: data.id.present ? data.id.value : this.id,
      cardApiId: data.cardApiId.present ? data.cardApiId.value : this.cardApiId,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      setName: data.setName.present ? data.setName.value : this.setName,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      targetPriceBrl: data.targetPriceBrl.present
          ? data.targetPriceBrl.value
          : this.targetPriceBrl,
      minTargetPriceBrl: data.minTargetPriceBrl.present
          ? data.minTargetPriceBrl.value
          : this.minTargetPriceBrl,
      condition: data.condition.present ? data.condition.value : this.condition,
      priority: data.priority.present ? data.priority.value : this.priority,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      language: data.language.present ? data.language.value : this.language,
      isPreSale: data.isPreSale.present ? data.isPreSale.value : this.isPreSale,
      currentPriceBrl: data.currentPriceBrl.present
          ? data.currentPriceBrl.value
          : this.currentPriceBrl,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItem(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('setName: $setName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('targetPriceBrl: $targetPriceBrl, ')
          ..write('minTargetPriceBrl: $minTargetPriceBrl, ')
          ..write('condition: $condition, ')
          ..write('priority: $priority, ')
          ..write('folderName: $folderName, ')
          ..write('language: $language, ')
          ..write('isPreSale: $isPreSale, ')
          ..write('currentPriceBrl: $currentPriceBrl, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardApiId,
    name,
    number,
    setName,
    imageUrl,
    targetPriceBrl,
    minTargetPriceBrl,
    condition,
    priority,
    folderName,
    language,
    isPreSale,
    currentPriceBrl,
    lastCheckedAt,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItem &&
          other.id == this.id &&
          other.cardApiId == this.cardApiId &&
          other.name == this.name &&
          other.number == this.number &&
          other.setName == this.setName &&
          other.imageUrl == this.imageUrl &&
          other.targetPriceBrl == this.targetPriceBrl &&
          other.minTargetPriceBrl == this.minTargetPriceBrl &&
          other.condition == this.condition &&
          other.priority == this.priority &&
          other.folderName == this.folderName &&
          other.language == this.language &&
          other.isPreSale == this.isPreSale &&
          other.currentPriceBrl == this.currentPriceBrl &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class WishlistItemsCompanion extends UpdateCompanion<WishlistItem> {
  final Value<String> id;
  final Value<String> cardApiId;
  final Value<String> name;
  final Value<String> number;
  final Value<String> setName;
  final Value<String> imageUrl;
  final Value<double> targetPriceBrl;
  final Value<double> minTargetPriceBrl;
  final Value<String> condition;
  final Value<String> priority;
  final Value<String> folderName;
  final Value<String> language;
  final Value<bool> isPreSale;
  final Value<double?> currentPriceBrl;
  final Value<DateTime?> lastCheckedAt;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WishlistItemsCompanion({
    this.id = const Value.absent(),
    this.cardApiId = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.setName = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.targetPriceBrl = const Value.absent(),
    this.minTargetPriceBrl = const Value.absent(),
    this.condition = const Value.absent(),
    this.priority = const Value.absent(),
    this.folderName = const Value.absent(),
    this.language = const Value.absent(),
    this.isPreSale = const Value.absent(),
    this.currentPriceBrl = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistItemsCompanion.insert({
    required String id,
    required String cardApiId,
    required String name,
    this.number = const Value.absent(),
    this.setName = const Value.absent(),
    required String imageUrl,
    this.targetPriceBrl = const Value.absent(),
    this.minTargetPriceBrl = const Value.absent(),
    this.condition = const Value.absent(),
    this.priority = const Value.absent(),
    this.folderName = const Value.absent(),
    this.language = const Value.absent(),
    this.isPreSale = const Value.absent(),
    this.currentPriceBrl = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardApiId = Value(cardApiId),
       name = Value(name),
       imageUrl = Value(imageUrl);
  static Insertable<WishlistItem> custom({
    Expression<String>? id,
    Expression<String>? cardApiId,
    Expression<String>? name,
    Expression<String>? number,
    Expression<String>? setName,
    Expression<String>? imageUrl,
    Expression<double>? targetPriceBrl,
    Expression<double>? minTargetPriceBrl,
    Expression<String>? condition,
    Expression<String>? priority,
    Expression<String>? folderName,
    Expression<String>? language,
    Expression<bool>? isPreSale,
    Expression<double>? currentPriceBrl,
    Expression<DateTime>? lastCheckedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardApiId != null) 'card_api_id': cardApiId,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (setName != null) 'set_name': setName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (targetPriceBrl != null) 'target_price_brl': targetPriceBrl,
      if (minTargetPriceBrl != null) 'min_target_price_brl': minTargetPriceBrl,
      if (condition != null) 'condition': condition,
      if (priority != null) 'priority': priority,
      if (folderName != null) 'folder_name': folderName,
      if (language != null) 'language': language,
      if (isPreSale != null) 'is_pre_sale': isPreSale,
      if (currentPriceBrl != null) 'current_price_brl': currentPriceBrl,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardApiId,
    Value<String>? name,
    Value<String>? number,
    Value<String>? setName,
    Value<String>? imageUrl,
    Value<double>? targetPriceBrl,
    Value<double>? minTargetPriceBrl,
    Value<String>? condition,
    Value<String>? priority,
    Value<String>? folderName,
    Value<String>? language,
    Value<bool>? isPreSale,
    Value<double?>? currentPriceBrl,
    Value<DateTime?>? lastCheckedAt,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WishlistItemsCompanion(
      id: id ?? this.id,
      cardApiId: cardApiId ?? this.cardApiId,
      name: name ?? this.name,
      number: number ?? this.number,
      setName: setName ?? this.setName,
      imageUrl: imageUrl ?? this.imageUrl,
      targetPriceBrl: targetPriceBrl ?? this.targetPriceBrl,
      minTargetPriceBrl: minTargetPriceBrl ?? this.minTargetPriceBrl,
      condition: condition ?? this.condition,
      priority: priority ?? this.priority,
      folderName: folderName ?? this.folderName,
      language: language ?? this.language,
      isPreSale: isPreSale ?? this.isPreSale,
      currentPriceBrl: currentPriceBrl ?? this.currentPriceBrl,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardApiId.present) {
      map['card_api_id'] = Variable<String>(cardApiId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (targetPriceBrl.present) {
      map['target_price_brl'] = Variable<double>(targetPriceBrl.value);
    }
    if (minTargetPriceBrl.present) {
      map['min_target_price_brl'] = Variable<double>(minTargetPriceBrl.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (isPreSale.present) {
      map['is_pre_sale'] = Variable<bool>(isPreSale.value);
    }
    if (currentPriceBrl.present) {
      map['current_price_brl'] = Variable<double>(currentPriceBrl.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('setName: $setName, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('targetPriceBrl: $targetPriceBrl, ')
          ..write('minTargetPriceBrl: $minTargetPriceBrl, ')
          ..write('condition: $condition, ')
          ..write('priority: $priority, ')
          ..write('folderName: $folderName, ')
          ..write('language: $language, ')
          ..write('isPreSale: $isPreSale, ')
          ..write('currentPriceBrl: $currentPriceBrl, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PriceSnapshotsTable extends PriceSnapshots
    with TableInfo<$PriceSnapshotsTable, PriceSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardApiIdMeta = const VerificationMeta(
    'cardApiId',
  );
  @override
  late final GeneratedColumn<String> cardApiId = GeneratedColumn<String>(
    'card_api_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _ligaMinBrlMeta = const VerificationMeta(
    'ligaMinBrl',
  );
  @override
  late final GeneratedColumn<double> ligaMinBrl = GeneratedColumn<double>(
    'liga_min_brl',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ligaAvgBrlMeta = const VerificationMeta(
    'ligaAvgBrl',
  );
  @override
  late final GeneratedColumn<double> ligaAvgBrl = GeneratedColumn<double>(
    'liga_avg_brl',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ligaMaxBrlMeta = const VerificationMeta(
    'ligaMaxBrl',
  );
  @override
  late final GeneratedColumn<double> ligaMaxBrl = GeneratedColumn<double>(
    'liga_max_brl',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tcgMarketUsdMeta = const VerificationMeta(
    'tcgMarketUsd',
  );
  @override
  late final GeneratedColumn<double> tcgMarketUsd = GeneratedColumn<double>(
    'tcg_market_usd',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exchangeRateBrlMeta = const VerificationMeta(
    'exchangeRateBrl',
  );
  @override
  late final GeneratedColumn<double> exchangeRateBrl = GeneratedColumn<double>(
    'exchange_rate_brl',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(5.60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardApiId,
    timestamp,
    ligaMinBrl,
    ligaAvgBrl,
    ligaMaxBrl,
    tcgMarketUsd,
    exchangeRateBrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_api_id')) {
      context.handle(
        _cardApiIdMeta,
        cardApiId.isAcceptableOrUnknown(data['card_api_id']!, _cardApiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardApiIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    if (data.containsKey('liga_min_brl')) {
      context.handle(
        _ligaMinBrlMeta,
        ligaMinBrl.isAcceptableOrUnknown(
          data['liga_min_brl']!,
          _ligaMinBrlMeta,
        ),
      );
    }
    if (data.containsKey('liga_avg_brl')) {
      context.handle(
        _ligaAvgBrlMeta,
        ligaAvgBrl.isAcceptableOrUnknown(
          data['liga_avg_brl']!,
          _ligaAvgBrlMeta,
        ),
      );
    }
    if (data.containsKey('liga_max_brl')) {
      context.handle(
        _ligaMaxBrlMeta,
        ligaMaxBrl.isAcceptableOrUnknown(
          data['liga_max_brl']!,
          _ligaMaxBrlMeta,
        ),
      );
    }
    if (data.containsKey('tcg_market_usd')) {
      context.handle(
        _tcgMarketUsdMeta,
        tcgMarketUsd.isAcceptableOrUnknown(
          data['tcg_market_usd']!,
          _tcgMarketUsdMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate_brl')) {
      context.handle(
        _exchangeRateBrlMeta,
        exchangeRateBrl.isAcceptableOrUnknown(
          data['exchange_rate_brl']!,
          _exchangeRateBrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PriceSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_api_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      ligaMinBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liga_min_brl'],
      ),
      ligaAvgBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liga_avg_brl'],
      ),
      ligaMaxBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liga_max_brl'],
      ),
      tcgMarketUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tcg_market_usd'],
      ),
      exchangeRateBrl: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate_brl'],
      )!,
    );
  }

  @override
  $PriceSnapshotsTable createAlias(String alias) {
    return $PriceSnapshotsTable(attachedDatabase, alias);
  }
}

class PriceSnapshot extends DataClass implements Insertable<PriceSnapshot> {
  final int id;
  final String cardApiId;
  final DateTime timestamp;
  final double? ligaMinBrl;
  final double? ligaAvgBrl;
  final double? ligaMaxBrl;
  final double? tcgMarketUsd;
  final double exchangeRateBrl;
  const PriceSnapshot({
    required this.id,
    required this.cardApiId,
    required this.timestamp,
    this.ligaMinBrl,
    this.ligaAvgBrl,
    this.ligaMaxBrl,
    this.tcgMarketUsd,
    required this.exchangeRateBrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_api_id'] = Variable<String>(cardApiId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || ligaMinBrl != null) {
      map['liga_min_brl'] = Variable<double>(ligaMinBrl);
    }
    if (!nullToAbsent || ligaAvgBrl != null) {
      map['liga_avg_brl'] = Variable<double>(ligaAvgBrl);
    }
    if (!nullToAbsent || ligaMaxBrl != null) {
      map['liga_max_brl'] = Variable<double>(ligaMaxBrl);
    }
    if (!nullToAbsent || tcgMarketUsd != null) {
      map['tcg_market_usd'] = Variable<double>(tcgMarketUsd);
    }
    map['exchange_rate_brl'] = Variable<double>(exchangeRateBrl);
    return map;
  }

  PriceSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return PriceSnapshotsCompanion(
      id: Value(id),
      cardApiId: Value(cardApiId),
      timestamp: Value(timestamp),
      ligaMinBrl: ligaMinBrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ligaMinBrl),
      ligaAvgBrl: ligaAvgBrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ligaAvgBrl),
      ligaMaxBrl: ligaMaxBrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ligaMaxBrl),
      tcgMarketUsd: tcgMarketUsd == null && nullToAbsent
          ? const Value.absent()
          : Value(tcgMarketUsd),
      exchangeRateBrl: Value(exchangeRateBrl),
    );
  }

  factory PriceSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceSnapshot(
      id: serializer.fromJson<int>(json['id']),
      cardApiId: serializer.fromJson<String>(json['cardApiId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      ligaMinBrl: serializer.fromJson<double?>(json['ligaMinBrl']),
      ligaAvgBrl: serializer.fromJson<double?>(json['ligaAvgBrl']),
      ligaMaxBrl: serializer.fromJson<double?>(json['ligaMaxBrl']),
      tcgMarketUsd: serializer.fromJson<double?>(json['tcgMarketUsd']),
      exchangeRateBrl: serializer.fromJson<double>(json['exchangeRateBrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardApiId': serializer.toJson<String>(cardApiId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'ligaMinBrl': serializer.toJson<double?>(ligaMinBrl),
      'ligaAvgBrl': serializer.toJson<double?>(ligaAvgBrl),
      'ligaMaxBrl': serializer.toJson<double?>(ligaMaxBrl),
      'tcgMarketUsd': serializer.toJson<double?>(tcgMarketUsd),
      'exchangeRateBrl': serializer.toJson<double>(exchangeRateBrl),
    };
  }

  PriceSnapshot copyWith({
    int? id,
    String? cardApiId,
    DateTime? timestamp,
    Value<double?> ligaMinBrl = const Value.absent(),
    Value<double?> ligaAvgBrl = const Value.absent(),
    Value<double?> ligaMaxBrl = const Value.absent(),
    Value<double?> tcgMarketUsd = const Value.absent(),
    double? exchangeRateBrl,
  }) => PriceSnapshot(
    id: id ?? this.id,
    cardApiId: cardApiId ?? this.cardApiId,
    timestamp: timestamp ?? this.timestamp,
    ligaMinBrl: ligaMinBrl.present ? ligaMinBrl.value : this.ligaMinBrl,
    ligaAvgBrl: ligaAvgBrl.present ? ligaAvgBrl.value : this.ligaAvgBrl,
    ligaMaxBrl: ligaMaxBrl.present ? ligaMaxBrl.value : this.ligaMaxBrl,
    tcgMarketUsd: tcgMarketUsd.present ? tcgMarketUsd.value : this.tcgMarketUsd,
    exchangeRateBrl: exchangeRateBrl ?? this.exchangeRateBrl,
  );
  PriceSnapshot copyWithCompanion(PriceSnapshotsCompanion data) {
    return PriceSnapshot(
      id: data.id.present ? data.id.value : this.id,
      cardApiId: data.cardApiId.present ? data.cardApiId.value : this.cardApiId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      ligaMinBrl: data.ligaMinBrl.present
          ? data.ligaMinBrl.value
          : this.ligaMinBrl,
      ligaAvgBrl: data.ligaAvgBrl.present
          ? data.ligaAvgBrl.value
          : this.ligaAvgBrl,
      ligaMaxBrl: data.ligaMaxBrl.present
          ? data.ligaMaxBrl.value
          : this.ligaMaxBrl,
      tcgMarketUsd: data.tcgMarketUsd.present
          ? data.tcgMarketUsd.value
          : this.tcgMarketUsd,
      exchangeRateBrl: data.exchangeRateBrl.present
          ? data.exchangeRateBrl.value
          : this.exchangeRateBrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceSnapshot(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('timestamp: $timestamp, ')
          ..write('ligaMinBrl: $ligaMinBrl, ')
          ..write('ligaAvgBrl: $ligaAvgBrl, ')
          ..write('ligaMaxBrl: $ligaMaxBrl, ')
          ..write('tcgMarketUsd: $tcgMarketUsd, ')
          ..write('exchangeRateBrl: $exchangeRateBrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardApiId,
    timestamp,
    ligaMinBrl,
    ligaAvgBrl,
    ligaMaxBrl,
    tcgMarketUsd,
    exchangeRateBrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceSnapshot &&
          other.id == this.id &&
          other.cardApiId == this.cardApiId &&
          other.timestamp == this.timestamp &&
          other.ligaMinBrl == this.ligaMinBrl &&
          other.ligaAvgBrl == this.ligaAvgBrl &&
          other.ligaMaxBrl == this.ligaMaxBrl &&
          other.tcgMarketUsd == this.tcgMarketUsd &&
          other.exchangeRateBrl == this.exchangeRateBrl);
}

class PriceSnapshotsCompanion extends UpdateCompanion<PriceSnapshot> {
  final Value<int> id;
  final Value<String> cardApiId;
  final Value<DateTime> timestamp;
  final Value<double?> ligaMinBrl;
  final Value<double?> ligaAvgBrl;
  final Value<double?> ligaMaxBrl;
  final Value<double?> tcgMarketUsd;
  final Value<double> exchangeRateBrl;
  const PriceSnapshotsCompanion({
    this.id = const Value.absent(),
    this.cardApiId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.ligaMinBrl = const Value.absent(),
    this.ligaAvgBrl = const Value.absent(),
    this.ligaMaxBrl = const Value.absent(),
    this.tcgMarketUsd = const Value.absent(),
    this.exchangeRateBrl = const Value.absent(),
  });
  PriceSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String cardApiId,
    this.timestamp = const Value.absent(),
    this.ligaMinBrl = const Value.absent(),
    this.ligaAvgBrl = const Value.absent(),
    this.ligaMaxBrl = const Value.absent(),
    this.tcgMarketUsd = const Value.absent(),
    this.exchangeRateBrl = const Value.absent(),
  }) : cardApiId = Value(cardApiId);
  static Insertable<PriceSnapshot> custom({
    Expression<int>? id,
    Expression<String>? cardApiId,
    Expression<DateTime>? timestamp,
    Expression<double>? ligaMinBrl,
    Expression<double>? ligaAvgBrl,
    Expression<double>? ligaMaxBrl,
    Expression<double>? tcgMarketUsd,
    Expression<double>? exchangeRateBrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardApiId != null) 'card_api_id': cardApiId,
      if (timestamp != null) 'timestamp': timestamp,
      if (ligaMinBrl != null) 'liga_min_brl': ligaMinBrl,
      if (ligaAvgBrl != null) 'liga_avg_brl': ligaAvgBrl,
      if (ligaMaxBrl != null) 'liga_max_brl': ligaMaxBrl,
      if (tcgMarketUsd != null) 'tcg_market_usd': tcgMarketUsd,
      if (exchangeRateBrl != null) 'exchange_rate_brl': exchangeRateBrl,
    });
  }

  PriceSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardApiId,
    Value<DateTime>? timestamp,
    Value<double?>? ligaMinBrl,
    Value<double?>? ligaAvgBrl,
    Value<double?>? ligaMaxBrl,
    Value<double?>? tcgMarketUsd,
    Value<double>? exchangeRateBrl,
  }) {
    return PriceSnapshotsCompanion(
      id: id ?? this.id,
      cardApiId: cardApiId ?? this.cardApiId,
      timestamp: timestamp ?? this.timestamp,
      ligaMinBrl: ligaMinBrl ?? this.ligaMinBrl,
      ligaAvgBrl: ligaAvgBrl ?? this.ligaAvgBrl,
      ligaMaxBrl: ligaMaxBrl ?? this.ligaMaxBrl,
      tcgMarketUsd: tcgMarketUsd ?? this.tcgMarketUsd,
      exchangeRateBrl: exchangeRateBrl ?? this.exchangeRateBrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardApiId.present) {
      map['card_api_id'] = Variable<String>(cardApiId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (ligaMinBrl.present) {
      map['liga_min_brl'] = Variable<double>(ligaMinBrl.value);
    }
    if (ligaAvgBrl.present) {
      map['liga_avg_brl'] = Variable<double>(ligaAvgBrl.value);
    }
    if (ligaMaxBrl.present) {
      map['liga_max_brl'] = Variable<double>(ligaMaxBrl.value);
    }
    if (tcgMarketUsd.present) {
      map['tcg_market_usd'] = Variable<double>(tcgMarketUsd.value);
    }
    if (exchangeRateBrl.present) {
      map['exchange_rate_brl'] = Variable<double>(exchangeRateBrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('cardApiId: $cardApiId, ')
          ..write('timestamp: $timestamp, ')
          ..write('ligaMinBrl: $ligaMinBrl, ')
          ..write('ligaAvgBrl: $ligaAvgBrl, ')
          ..write('ligaMaxBrl: $ligaMaxBrl, ')
          ..write('tcgMarketUsd: $tcgMarketUsd, ')
          ..write('exchangeRateBrl: $exchangeRateBrl')
          ..write(')'))
        .toString();
  }
}

class $LigaPriceAlertsTable extends LigaPriceAlerts
    with TableInfo<$LigaPriceAlertsTable, LigaPriceAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LigaPriceAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetUrlMeta = const VerificationMeta(
    'targetUrl',
  );
  @override
  late final GeneratedColumn<String> targetUrl = GeneratedColumn<String>(
    'target_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _collectionTagMeta = const VerificationMeta(
    'collectionTag',
  );
  @override
  late final GeneratedColumn<String> collectionTag = GeneratedColumn<String>(
    'collection_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _languageTagMeta = const VerificationMeta(
    'languageTag',
  );
  @override
  late final GeneratedColumn<String> languageTag = GeneratedColumn<String>(
    'language_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _minTargetPriceMeta = const VerificationMeta(
    'minTargetPrice',
  );
  @override
  late final GeneratedColumn<double> minTargetPrice = GeneratedColumn<double>(
    'min_target_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _maxTargetPriceMeta = const VerificationMeta(
    'maxTargetPrice',
  );
  @override
  late final GeneratedColumn<double> maxTargetPrice = GeneratedColumn<double>(
    'max_target_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _allowPreSaleMeta = const VerificationMeta(
    'allowPreSale',
  );
  @override
  late final GeneratedColumn<bool> allowPreSale = GeneratedColumn<bool>(
    'allow_pre_sale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_pre_sale" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _currentLowestPriceMeta =
      const VerificationMeta('currentLowestPrice');
  @override
  late final GeneratedColumn<double> currentLowestPrice =
      GeneratedColumn<double>(
        'current_lowest_price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentStoreNameMeta = const VerificationMeta(
    'currentStoreName',
  );
  @override
  late final GeneratedColumn<String> currentStoreName = GeneratedColumn<String>(
    'current_store_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPreSaleMeta = const VerificationMeta(
    'isPreSale',
  );
  @override
  late final GeneratedColumn<bool> isPreSale = GeneratedColumn<bool>(
    'is_pre_sale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pre_sale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isAvailableInRangeMeta =
      const VerificationMeta('isAvailableInRange');
  @override
  late final GeneratedColumn<bool> isAvailableInRange = GeneratedColumn<bool>(
    'is_available_in_range',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available_in_range" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastCheckedAtMeta = const VerificationMeta(
    'lastCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckedAt =
      GeneratedColumn<DateTime>(
        'last_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastNotifiedAtMeta = const VerificationMeta(
    'lastNotifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastNotifiedAt =
      GeneratedColumn<DateTime>(
        'last_notified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    targetUrl,
    imageUrl,
    collectionTag,
    languageTag,
    minTargetPrice,
    maxTargetPrice,
    allowPreSale,
    currentLowestPrice,
    currentStoreName,
    isPreSale,
    isAvailableInRange,
    isActive,
    lastCheckedAt,
    lastNotifiedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'liga_price_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LigaPriceAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_url')) {
      context.handle(
        _targetUrlMeta,
        targetUrl.isAcceptableOrUnknown(data['target_url']!, _targetUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_targetUrlMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('collection_tag')) {
      context.handle(
        _collectionTagMeta,
        collectionTag.isAcceptableOrUnknown(
          data['collection_tag']!,
          _collectionTagMeta,
        ),
      );
    }
    if (data.containsKey('language_tag')) {
      context.handle(
        _languageTagMeta,
        languageTag.isAcceptableOrUnknown(
          data['language_tag']!,
          _languageTagMeta,
        ),
      );
    }
    if (data.containsKey('min_target_price')) {
      context.handle(
        _minTargetPriceMeta,
        minTargetPrice.isAcceptableOrUnknown(
          data['min_target_price']!,
          _minTargetPriceMeta,
        ),
      );
    }
    if (data.containsKey('max_target_price')) {
      context.handle(
        _maxTargetPriceMeta,
        maxTargetPrice.isAcceptableOrUnknown(
          data['max_target_price']!,
          _maxTargetPriceMeta,
        ),
      );
    }
    if (data.containsKey('allow_pre_sale')) {
      context.handle(
        _allowPreSaleMeta,
        allowPreSale.isAcceptableOrUnknown(
          data['allow_pre_sale']!,
          _allowPreSaleMeta,
        ),
      );
    }
    if (data.containsKey('current_lowest_price')) {
      context.handle(
        _currentLowestPriceMeta,
        currentLowestPrice.isAcceptableOrUnknown(
          data['current_lowest_price']!,
          _currentLowestPriceMeta,
        ),
      );
    }
    if (data.containsKey('current_store_name')) {
      context.handle(
        _currentStoreNameMeta,
        currentStoreName.isAcceptableOrUnknown(
          data['current_store_name']!,
          _currentStoreNameMeta,
        ),
      );
    }
    if (data.containsKey('is_pre_sale')) {
      context.handle(
        _isPreSaleMeta,
        isPreSale.isAcceptableOrUnknown(data['is_pre_sale']!, _isPreSaleMeta),
      );
    }
    if (data.containsKey('is_available_in_range')) {
      context.handle(
        _isAvailableInRangeMeta,
        isAvailableInRange.isAcceptableOrUnknown(
          data['is_available_in_range']!,
          _isAvailableInRangeMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_checked_at')) {
      context.handle(
        _lastCheckedAtMeta,
        lastCheckedAt.isAcceptableOrUnknown(
          data['last_checked_at']!,
          _lastCheckedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_notified_at')) {
      context.handle(
        _lastNotifiedAtMeta,
        lastNotifiedAt.isAcceptableOrUnknown(
          data['last_notified_at']!,
          _lastNotifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LigaPriceAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LigaPriceAlert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      targetUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_url'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      collectionTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_tag'],
      )!,
      languageTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_tag'],
      )!,
      minTargetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_target_price'],
      )!,
      maxTargetPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_target_price'],
      )!,
      allowPreSale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_pre_sale'],
      )!,
      currentLowestPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_lowest_price'],
      ),
      currentStoreName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_store_name'],
      )!,
      isPreSale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pre_sale'],
      )!,
      isAvailableInRange: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available_in_range'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked_at'],
      ),
      lastNotifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_notified_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LigaPriceAlertsTable createAlias(String alias) {
    return $LigaPriceAlertsTable(attachedDatabase, alias);
  }
}

class LigaPriceAlert extends DataClass implements Insertable<LigaPriceAlert> {
  final String id;
  final String title;
  final String targetUrl;
  final String imageUrl;
  final String collectionTag;
  final String languageTag;
  final double minTargetPrice;
  final double maxTargetPrice;
  final bool allowPreSale;
  final double? currentLowestPrice;
  final String currentStoreName;
  final bool isPreSale;
  final bool isAvailableInRange;
  final bool isActive;
  final DateTime? lastCheckedAt;
  final DateTime? lastNotifiedAt;
  final DateTime createdAt;
  const LigaPriceAlert({
    required this.id,
    required this.title,
    required this.targetUrl,
    required this.imageUrl,
    required this.collectionTag,
    required this.languageTag,
    required this.minTargetPrice,
    required this.maxTargetPrice,
    required this.allowPreSale,
    this.currentLowestPrice,
    required this.currentStoreName,
    required this.isPreSale,
    required this.isAvailableInRange,
    required this.isActive,
    this.lastCheckedAt,
    this.lastNotifiedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['target_url'] = Variable<String>(targetUrl);
    map['image_url'] = Variable<String>(imageUrl);
    map['collection_tag'] = Variable<String>(collectionTag);
    map['language_tag'] = Variable<String>(languageTag);
    map['min_target_price'] = Variable<double>(minTargetPrice);
    map['max_target_price'] = Variable<double>(maxTargetPrice);
    map['allow_pre_sale'] = Variable<bool>(allowPreSale);
    if (!nullToAbsent || currentLowestPrice != null) {
      map['current_lowest_price'] = Variable<double>(currentLowestPrice);
    }
    map['current_store_name'] = Variable<String>(currentStoreName);
    map['is_pre_sale'] = Variable<bool>(isPreSale);
    map['is_available_in_range'] = Variable<bool>(isAvailableInRange);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastCheckedAt != null) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt);
    }
    if (!nullToAbsent || lastNotifiedAt != null) {
      map['last_notified_at'] = Variable<DateTime>(lastNotifiedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LigaPriceAlertsCompanion toCompanion(bool nullToAbsent) {
    return LigaPriceAlertsCompanion(
      id: Value(id),
      title: Value(title),
      targetUrl: Value(targetUrl),
      imageUrl: Value(imageUrl),
      collectionTag: Value(collectionTag),
      languageTag: Value(languageTag),
      minTargetPrice: Value(minTargetPrice),
      maxTargetPrice: Value(maxTargetPrice),
      allowPreSale: Value(allowPreSale),
      currentLowestPrice: currentLowestPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(currentLowestPrice),
      currentStoreName: Value(currentStoreName),
      isPreSale: Value(isPreSale),
      isAvailableInRange: Value(isAvailableInRange),
      isActive: Value(isActive),
      lastCheckedAt: lastCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheckedAt),
      lastNotifiedAt: lastNotifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedAt),
      createdAt: Value(createdAt),
    );
  }

  factory LigaPriceAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LigaPriceAlert(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      targetUrl: serializer.fromJson<String>(json['targetUrl']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      collectionTag: serializer.fromJson<String>(json['collectionTag']),
      languageTag: serializer.fromJson<String>(json['languageTag']),
      minTargetPrice: serializer.fromJson<double>(json['minTargetPrice']),
      maxTargetPrice: serializer.fromJson<double>(json['maxTargetPrice']),
      allowPreSale: serializer.fromJson<bool>(json['allowPreSale']),
      currentLowestPrice: serializer.fromJson<double?>(
        json['currentLowestPrice'],
      ),
      currentStoreName: serializer.fromJson<String>(json['currentStoreName']),
      isPreSale: serializer.fromJson<bool>(json['isPreSale']),
      isAvailableInRange: serializer.fromJson<bool>(json['isAvailableInRange']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastCheckedAt: serializer.fromJson<DateTime?>(json['lastCheckedAt']),
      lastNotifiedAt: serializer.fromJson<DateTime?>(json['lastNotifiedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'targetUrl': serializer.toJson<String>(targetUrl),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'collectionTag': serializer.toJson<String>(collectionTag),
      'languageTag': serializer.toJson<String>(languageTag),
      'minTargetPrice': serializer.toJson<double>(minTargetPrice),
      'maxTargetPrice': serializer.toJson<double>(maxTargetPrice),
      'allowPreSale': serializer.toJson<bool>(allowPreSale),
      'currentLowestPrice': serializer.toJson<double?>(currentLowestPrice),
      'currentStoreName': serializer.toJson<String>(currentStoreName),
      'isPreSale': serializer.toJson<bool>(isPreSale),
      'isAvailableInRange': serializer.toJson<bool>(isAvailableInRange),
      'isActive': serializer.toJson<bool>(isActive),
      'lastCheckedAt': serializer.toJson<DateTime?>(lastCheckedAt),
      'lastNotifiedAt': serializer.toJson<DateTime?>(lastNotifiedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LigaPriceAlert copyWith({
    String? id,
    String? title,
    String? targetUrl,
    String? imageUrl,
    String? collectionTag,
    String? languageTag,
    double? minTargetPrice,
    double? maxTargetPrice,
    bool? allowPreSale,
    Value<double?> currentLowestPrice = const Value.absent(),
    String? currentStoreName,
    bool? isPreSale,
    bool? isAvailableInRange,
    bool? isActive,
    Value<DateTime?> lastCheckedAt = const Value.absent(),
    Value<DateTime?> lastNotifiedAt = const Value.absent(),
    DateTime? createdAt,
  }) => LigaPriceAlert(
    id: id ?? this.id,
    title: title ?? this.title,
    targetUrl: targetUrl ?? this.targetUrl,
    imageUrl: imageUrl ?? this.imageUrl,
    collectionTag: collectionTag ?? this.collectionTag,
    languageTag: languageTag ?? this.languageTag,
    minTargetPrice: minTargetPrice ?? this.minTargetPrice,
    maxTargetPrice: maxTargetPrice ?? this.maxTargetPrice,
    allowPreSale: allowPreSale ?? this.allowPreSale,
    currentLowestPrice: currentLowestPrice.present
        ? currentLowestPrice.value
        : this.currentLowestPrice,
    currentStoreName: currentStoreName ?? this.currentStoreName,
    isPreSale: isPreSale ?? this.isPreSale,
    isAvailableInRange: isAvailableInRange ?? this.isAvailableInRange,
    isActive: isActive ?? this.isActive,
    lastCheckedAt: lastCheckedAt.present
        ? lastCheckedAt.value
        : this.lastCheckedAt,
    lastNotifiedAt: lastNotifiedAt.present
        ? lastNotifiedAt.value
        : this.lastNotifiedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  LigaPriceAlert copyWithCompanion(LigaPriceAlertsCompanion data) {
    return LigaPriceAlert(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      targetUrl: data.targetUrl.present ? data.targetUrl.value : this.targetUrl,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      collectionTag: data.collectionTag.present
          ? data.collectionTag.value
          : this.collectionTag,
      languageTag: data.languageTag.present
          ? data.languageTag.value
          : this.languageTag,
      minTargetPrice: data.minTargetPrice.present
          ? data.minTargetPrice.value
          : this.minTargetPrice,
      maxTargetPrice: data.maxTargetPrice.present
          ? data.maxTargetPrice.value
          : this.maxTargetPrice,
      allowPreSale: data.allowPreSale.present
          ? data.allowPreSale.value
          : this.allowPreSale,
      currentLowestPrice: data.currentLowestPrice.present
          ? data.currentLowestPrice.value
          : this.currentLowestPrice,
      currentStoreName: data.currentStoreName.present
          ? data.currentStoreName.value
          : this.currentStoreName,
      isPreSale: data.isPreSale.present ? data.isPreSale.value : this.isPreSale,
      isAvailableInRange: data.isAvailableInRange.present
          ? data.isAvailableInRange.value
          : this.isAvailableInRange,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastCheckedAt: data.lastCheckedAt.present
          ? data.lastCheckedAt.value
          : this.lastCheckedAt,
      lastNotifiedAt: data.lastNotifiedAt.present
          ? data.lastNotifiedAt.value
          : this.lastNotifiedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LigaPriceAlert(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('collectionTag: $collectionTag, ')
          ..write('languageTag: $languageTag, ')
          ..write('minTargetPrice: $minTargetPrice, ')
          ..write('maxTargetPrice: $maxTargetPrice, ')
          ..write('allowPreSale: $allowPreSale, ')
          ..write('currentLowestPrice: $currentLowestPrice, ')
          ..write('currentStoreName: $currentStoreName, ')
          ..write('isPreSale: $isPreSale, ')
          ..write('isAvailableInRange: $isAvailableInRange, ')
          ..write('isActive: $isActive, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastNotifiedAt: $lastNotifiedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    targetUrl,
    imageUrl,
    collectionTag,
    languageTag,
    minTargetPrice,
    maxTargetPrice,
    allowPreSale,
    currentLowestPrice,
    currentStoreName,
    isPreSale,
    isAvailableInRange,
    isActive,
    lastCheckedAt,
    lastNotifiedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LigaPriceAlert &&
          other.id == this.id &&
          other.title == this.title &&
          other.targetUrl == this.targetUrl &&
          other.imageUrl == this.imageUrl &&
          other.collectionTag == this.collectionTag &&
          other.languageTag == this.languageTag &&
          other.minTargetPrice == this.minTargetPrice &&
          other.maxTargetPrice == this.maxTargetPrice &&
          other.allowPreSale == this.allowPreSale &&
          other.currentLowestPrice == this.currentLowestPrice &&
          other.currentStoreName == this.currentStoreName &&
          other.isPreSale == this.isPreSale &&
          other.isAvailableInRange == this.isAvailableInRange &&
          other.isActive == this.isActive &&
          other.lastCheckedAt == this.lastCheckedAt &&
          other.lastNotifiedAt == this.lastNotifiedAt &&
          other.createdAt == this.createdAt);
}

class LigaPriceAlertsCompanion extends UpdateCompanion<LigaPriceAlert> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> targetUrl;
  final Value<String> imageUrl;
  final Value<String> collectionTag;
  final Value<String> languageTag;
  final Value<double> minTargetPrice;
  final Value<double> maxTargetPrice;
  final Value<bool> allowPreSale;
  final Value<double?> currentLowestPrice;
  final Value<String> currentStoreName;
  final Value<bool> isPreSale;
  final Value<bool> isAvailableInRange;
  final Value<bool> isActive;
  final Value<DateTime?> lastCheckedAt;
  final Value<DateTime?> lastNotifiedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LigaPriceAlertsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.targetUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.collectionTag = const Value.absent(),
    this.languageTag = const Value.absent(),
    this.minTargetPrice = const Value.absent(),
    this.maxTargetPrice = const Value.absent(),
    this.allowPreSale = const Value.absent(),
    this.currentLowestPrice = const Value.absent(),
    this.currentStoreName = const Value.absent(),
    this.isPreSale = const Value.absent(),
    this.isAvailableInRange = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastNotifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LigaPriceAlertsCompanion.insert({
    required String id,
    required String title,
    required String targetUrl,
    this.imageUrl = const Value.absent(),
    this.collectionTag = const Value.absent(),
    this.languageTag = const Value.absent(),
    this.minTargetPrice = const Value.absent(),
    this.maxTargetPrice = const Value.absent(),
    this.allowPreSale = const Value.absent(),
    this.currentLowestPrice = const Value.absent(),
    this.currentStoreName = const Value.absent(),
    this.isPreSale = const Value.absent(),
    this.isAvailableInRange = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastCheckedAt = const Value.absent(),
    this.lastNotifiedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       targetUrl = Value(targetUrl);
  static Insertable<LigaPriceAlert> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? targetUrl,
    Expression<String>? imageUrl,
    Expression<String>? collectionTag,
    Expression<String>? languageTag,
    Expression<double>? minTargetPrice,
    Expression<double>? maxTargetPrice,
    Expression<bool>? allowPreSale,
    Expression<double>? currentLowestPrice,
    Expression<String>? currentStoreName,
    Expression<bool>? isPreSale,
    Expression<bool>? isAvailableInRange,
    Expression<bool>? isActive,
    Expression<DateTime>? lastCheckedAt,
    Expression<DateTime>? lastNotifiedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (targetUrl != null) 'target_url': targetUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      if (collectionTag != null) 'collection_tag': collectionTag,
      if (languageTag != null) 'language_tag': languageTag,
      if (minTargetPrice != null) 'min_target_price': minTargetPrice,
      if (maxTargetPrice != null) 'max_target_price': maxTargetPrice,
      if (allowPreSale != null) 'allow_pre_sale': allowPreSale,
      if (currentLowestPrice != null)
        'current_lowest_price': currentLowestPrice,
      if (currentStoreName != null) 'current_store_name': currentStoreName,
      if (isPreSale != null) 'is_pre_sale': isPreSale,
      if (isAvailableInRange != null)
        'is_available_in_range': isAvailableInRange,
      if (isActive != null) 'is_active': isActive,
      if (lastCheckedAt != null) 'last_checked_at': lastCheckedAt,
      if (lastNotifiedAt != null) 'last_notified_at': lastNotifiedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LigaPriceAlertsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? targetUrl,
    Value<String>? imageUrl,
    Value<String>? collectionTag,
    Value<String>? languageTag,
    Value<double>? minTargetPrice,
    Value<double>? maxTargetPrice,
    Value<bool>? allowPreSale,
    Value<double?>? currentLowestPrice,
    Value<String>? currentStoreName,
    Value<bool>? isPreSale,
    Value<bool>? isAvailableInRange,
    Value<bool>? isActive,
    Value<DateTime?>? lastCheckedAt,
    Value<DateTime?>? lastNotifiedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LigaPriceAlertsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      targetUrl: targetUrl ?? this.targetUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      collectionTag: collectionTag ?? this.collectionTag,
      languageTag: languageTag ?? this.languageTag,
      minTargetPrice: minTargetPrice ?? this.minTargetPrice,
      maxTargetPrice: maxTargetPrice ?? this.maxTargetPrice,
      allowPreSale: allowPreSale ?? this.allowPreSale,
      currentLowestPrice: currentLowestPrice ?? this.currentLowestPrice,
      currentStoreName: currentStoreName ?? this.currentStoreName,
      isPreSale: isPreSale ?? this.isPreSale,
      isAvailableInRange: isAvailableInRange ?? this.isAvailableInRange,
      isActive: isActive ?? this.isActive,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetUrl.present) {
      map['target_url'] = Variable<String>(targetUrl.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (collectionTag.present) {
      map['collection_tag'] = Variable<String>(collectionTag.value);
    }
    if (languageTag.present) {
      map['language_tag'] = Variable<String>(languageTag.value);
    }
    if (minTargetPrice.present) {
      map['min_target_price'] = Variable<double>(minTargetPrice.value);
    }
    if (maxTargetPrice.present) {
      map['max_target_price'] = Variable<double>(maxTargetPrice.value);
    }
    if (allowPreSale.present) {
      map['allow_pre_sale'] = Variable<bool>(allowPreSale.value);
    }
    if (currentLowestPrice.present) {
      map['current_lowest_price'] = Variable<double>(currentLowestPrice.value);
    }
    if (currentStoreName.present) {
      map['current_store_name'] = Variable<String>(currentStoreName.value);
    }
    if (isPreSale.present) {
      map['is_pre_sale'] = Variable<bool>(isPreSale.value);
    }
    if (isAvailableInRange.present) {
      map['is_available_in_range'] = Variable<bool>(isAvailableInRange.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastCheckedAt.present) {
      map['last_checked_at'] = Variable<DateTime>(lastCheckedAt.value);
    }
    if (lastNotifiedAt.present) {
      map['last_notified_at'] = Variable<DateTime>(lastNotifiedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LigaPriceAlertsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('collectionTag: $collectionTag, ')
          ..write('languageTag: $languageTag, ')
          ..write('minTargetPrice: $minTargetPrice, ')
          ..write('maxTargetPrice: $maxTargetPrice, ')
          ..write('allowPreSale: $allowPreSale, ')
          ..write('currentLowestPrice: $currentLowestPrice, ')
          ..write('currentStoreName: $currentStoreName, ')
          ..write('isPreSale: $isPreSale, ')
          ..write('isAvailableInRange: $isAvailableInRange, ')
          ..write('isActive: $isActive, ')
          ..write('lastCheckedAt: $lastCheckedAt, ')
          ..write('lastNotifiedAt: $lastNotifiedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $UserCardsTable userCards = $UserCardsTable(this);
  late final $WishlistItemsTable wishlistItems = $WishlistItemsTable(this);
  late final $PriceSnapshotsTable priceSnapshots = $PriceSnapshotsTable(this);
  late final $LigaPriceAlertsTable ligaPriceAlerts = $LigaPriceAlertsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    userCards,
    wishlistItems,
    priceSnapshots,
    ligaPriceAlerts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_cards', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  required String id,
  required String name,
  Value<String> description,
  Value<String> colorTag,
  Value<String> iconName,
  Value<String> displayMode,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> description,
  Value<String> colorTag,
  Value<String> iconName,
  Value<String> displayMode,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserCardsTable, List<UserCard>>
  _userCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userCards,
    aliasName: 'folders__id__user_cards__folder_id',
  );

  $$UserCardsTableProcessedTableManager get userCardsRefs {
    final manager = $$UserCardsTableTableManager(
      $_db,
      $_db.userCards,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayMode => $composableBuilder(
    column: $table.displayMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userCardsRefs(
    Expression<bool> Function($$UserCardsTableFilterComposer f) f,
  ) {
    final $$UserCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCards,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCardsTableFilterComposer(
            $db: $db,
            $table: $db.userCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorTag => $composableBuilder(
    column: $table.colorTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayMode => $composableBuilder(
    column: $table.displayMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorTag =>
      $composableBuilder(column: $table.colorTag, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get displayMode => $composableBuilder(
    column: $table.displayMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> userCardsRefs<T extends Object>(
    Expression<T> Function($$UserCardsTableAnnotationComposer a) f,
  ) {
    final $$UserCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCards,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.userCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool userCardsRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> colorTag = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> displayMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                name: name,
                description: description,
                colorTag: colorTag,
                iconName: iconName,
                displayMode: displayMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> colorTag = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> displayMode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                name: name,
                description: description,
                colorTag: colorTag,
                iconName: iconName,
                displayMode: displayMode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoldersTable, Folder>(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userCardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userCardsRefs) db.userCards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userCardsRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, UserCard>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._userCardsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).userCardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool userCardsRefs})
    >;
typedef $$UserCardsTableCreateCompanionBuilder = UserCardsCompanion Function({
  required String id,
  required String cardApiId,
  required String name,
  Value<String> number,
  Value<String> setName,
  Value<String> rarity,
  required String imageUrl,
  Value<String?> folderId,
  Value<String> condition,
  Value<String> language,
  Value<String> finish,
  Value<int> quantity,
  Value<double> purchasePriceBrl,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$UserCardsTableUpdateCompanionBuilder = UserCardsCompanion Function({
  Value<String> id,
  Value<String> cardApiId,
  Value<String> name,
  Value<String> number,
  Value<String> setName,
  Value<String> rarity,
  Value<String> imageUrl,
  Value<String?> folderId,
  Value<String> condition,
  Value<String> language,
  Value<String> finish,
  Value<int> quantity,
  Value<double> purchasePriceBrl,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$UserCardsTableReferences
    extends BaseReferences<_$AppDatabase, $UserCardsTable, UserCard> {
  $$UserCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias('user_cards__folder_id__folders__id');

  $$FoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserCardsTableFilterComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finish => $composableBuilder(
    column: $table.finish,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePriceBrl => $composableBuilder(
    column: $table.purchasePriceBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finish => $composableBuilder(
    column: $table.finish,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePriceBrl => $composableBuilder(
    column: $table.purchasePriceBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardApiId =>
      $composableBuilder(column: $table.cardApiId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get finish =>
      $composableBuilder(column: $table.finish, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get purchasePriceBrl => $composableBuilder(
    column: $table.purchasePriceBrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCardsTable,
          UserCard,
          $$UserCardsTableFilterComposer,
          $$UserCardsTableOrderingComposer,
          $$UserCardsTableAnnotationComposer,
          $$UserCardsTableCreateCompanionBuilder,
          $$UserCardsTableUpdateCompanionBuilder,
          (UserCard, $$UserCardsTableReferences),
          UserCard,
          PrefetchHooks Function({bool folderId})
        > {
  $$UserCardsTableTableManager(_$AppDatabase db, $UserCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardApiId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> finish = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> purchasePriceBrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion(
                id: id,
                cardApiId: cardApiId,
                name: name,
                number: number,
                setName: setName,
                rarity: rarity,
                imageUrl: imageUrl,
                folderId: folderId,
                condition: condition,
                language: language,
                finish: finish,
                quantity: quantity,
                purchasePriceBrl: purchasePriceBrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardApiId,
                required String name,
                Value<String> number = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> rarity = const Value.absent(),
                required String imageUrl,
                Value<String?> folderId = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> finish = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> purchasePriceBrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion.insert(
                id: id,
                cardApiId: cardApiId,
                name: name,
                number: number,
                setName: setName,
                rarity: rarity,
                imageUrl: imageUrl,
                folderId: folderId,
                condition: condition,
                language: language,
                finish: finish,
                quantity: quantity,
                purchasePriceBrl: purchasePriceBrl,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserCardsTable, UserCard>(table),
                  $$UserCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$UserCardsTableReferences
                            ._folderIdTable(db),
                        referencedColumn: $$UserCardsTableReferences
                            ._folderIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCardsTable,
      UserCard,
      $$UserCardsTableFilterComposer,
      $$UserCardsTableOrderingComposer,
      $$UserCardsTableAnnotationComposer,
      $$UserCardsTableCreateCompanionBuilder,
      $$UserCardsTableUpdateCompanionBuilder,
      (UserCard, $$UserCardsTableReferences),
      UserCard,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$WishlistItemsTableCreateCompanionBuilder =
    WishlistItemsCompanion Function({
      required String id,
      required String cardApiId,
      required String name,
      Value<String> number,
      Value<String> setName,
      required String imageUrl,
      Value<double> targetPriceBrl,
      Value<double> minTargetPriceBrl,
      Value<String> condition,
      Value<String> priority,
      Value<String> folderName,
      Value<String> language,
      Value<bool> isPreSale,
      Value<double?> currentPriceBrl,
      Value<DateTime?> lastCheckedAt,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$WishlistItemsTableUpdateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<String> id,
      Value<String> cardApiId,
      Value<String> name,
      Value<String> number,
      Value<String> setName,
      Value<String> imageUrl,
      Value<double> targetPriceBrl,
      Value<double> minTargetPriceBrl,
      Value<String> condition,
      Value<String> priority,
      Value<String> folderName,
      Value<String> language,
      Value<bool> isPreSale,
      Value<double?> currentPriceBrl,
      Value<DateTime?> lastCheckedAt,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WishlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPriceBrl => $composableBuilder(
    column: $table.targetPriceBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minTargetPriceBrl => $composableBuilder(
    column: $table.minTargetPriceBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreSale => $composableBuilder(
    column: $table.isPreSale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentPriceBrl => $composableBuilder(
    column: $table.currentPriceBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WishlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPriceBrl => $composableBuilder(
    column: $table.targetPriceBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minTargetPriceBrl => $composableBuilder(
    column: $table.minTargetPriceBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreSale => $composableBuilder(
    column: $table.isPreSale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentPriceBrl => $composableBuilder(
    column: $table.currentPriceBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WishlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardApiId =>
      $composableBuilder(column: $table.cardApiId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get targetPriceBrl => $composableBuilder(
    column: $table.targetPriceBrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minTargetPriceBrl => $composableBuilder(
    column: $table.minTargetPriceBrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get isPreSale =>
      $composableBuilder(column: $table.isPreSale, builder: (column) => column);

  GeneratedColumn<double> get currentPriceBrl => $composableBuilder(
    column: $table.currentPriceBrl,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WishlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistItemsTable,
          WishlistItem,
          $$WishlistItemsTableFilterComposer,
          $$WishlistItemsTableOrderingComposer,
          $$WishlistItemsTableAnnotationComposer,
          $$WishlistItemsTableCreateCompanionBuilder,
          $$WishlistItemsTableUpdateCompanionBuilder,
          (
            WishlistItem,
            BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
          ),
          WishlistItem,
          PrefetchHooks Function()
        > {
  $$WishlistItemsTableTableManager(_$AppDatabase db, $WishlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardApiId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<String> setName = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<double> targetPriceBrl = const Value.absent(),
                Value<double> minTargetPriceBrl = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> isPreSale = const Value.absent(),
                Value<double?> currentPriceBrl = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion(
                id: id,
                cardApiId: cardApiId,
                name: name,
                number: number,
                setName: setName,
                imageUrl: imageUrl,
                targetPriceBrl: targetPriceBrl,
                minTargetPriceBrl: minTargetPriceBrl,
                condition: condition,
                priority: priority,
                folderName: folderName,
                language: language,
                isPreSale: isPreSale,
                currentPriceBrl: currentPriceBrl,
                lastCheckedAt: lastCheckedAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardApiId,
                required String name,
                Value<String> number = const Value.absent(),
                Value<String> setName = const Value.absent(),
                required String imageUrl,
                Value<double> targetPriceBrl = const Value.absent(),
                Value<double> minTargetPriceBrl = const Value.absent(),
                Value<String> condition = const Value.absent(),
                Value<String> priority = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> isPreSale = const Value.absent(),
                Value<double?> currentPriceBrl = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion.insert(
                id: id,
                cardApiId: cardApiId,
                name: name,
                number: number,
                setName: setName,
                imageUrl: imageUrl,
                targetPriceBrl: targetPriceBrl,
                minTargetPriceBrl: minTargetPriceBrl,
                condition: condition,
                priority: priority,
                folderName: folderName,
                language: language,
                isPreSale: isPreSale,
                currentPriceBrl: currentPriceBrl,
                lastCheckedAt: lastCheckedAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WishlistItemsTable, WishlistItem>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WishlistItemsTable,
                    WishlistItem
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WishlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistItemsTable,
      WishlistItem,
      $$WishlistItemsTableFilterComposer,
      $$WishlistItemsTableOrderingComposer,
      $$WishlistItemsTableAnnotationComposer,
      $$WishlistItemsTableCreateCompanionBuilder,
      $$WishlistItemsTableUpdateCompanionBuilder,
      (
        WishlistItem,
        BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem>,
      ),
      WishlistItem,
      PrefetchHooks Function()
    >;
typedef $$PriceSnapshotsTableCreateCompanionBuilder =
    PriceSnapshotsCompanion Function({
      Value<int> id,
      required String cardApiId,
      Value<DateTime> timestamp,
      Value<double?> ligaMinBrl,
      Value<double?> ligaAvgBrl,
      Value<double?> ligaMaxBrl,
      Value<double?> tcgMarketUsd,
      Value<double> exchangeRateBrl,
    });
typedef $$PriceSnapshotsTableUpdateCompanionBuilder =
    PriceSnapshotsCompanion Function({
      Value<int> id,
      Value<String> cardApiId,
      Value<DateTime> timestamp,
      Value<double?> ligaMinBrl,
      Value<double?> ligaAvgBrl,
      Value<double?> ligaMaxBrl,
      Value<double?> tcgMarketUsd,
      Value<double> exchangeRateBrl,
    });

class $$PriceSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ligaMinBrl => $composableBuilder(
    column: $table.ligaMinBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ligaAvgBrl => $composableBuilder(
    column: $table.ligaAvgBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ligaMaxBrl => $composableBuilder(
    column: $table.ligaMaxBrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcgMarketUsd => $composableBuilder(
    column: $table.tcgMarketUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRateBrl => $composableBuilder(
    column: $table.exchangeRateBrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardApiId => $composableBuilder(
    column: $table.cardApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ligaMinBrl => $composableBuilder(
    column: $table.ligaMinBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ligaAvgBrl => $composableBuilder(
    column: $table.ligaAvgBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ligaMaxBrl => $composableBuilder(
    column: $table.ligaMaxBrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcgMarketUsd => $composableBuilder(
    column: $table.tcgMarketUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRateBrl => $composableBuilder(
    column: $table.exchangeRateBrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceSnapshotsTable> {
  $$PriceSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardApiId =>
      $composableBuilder(column: $table.cardApiId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get ligaMinBrl => $composableBuilder(
    column: $table.ligaMinBrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ligaAvgBrl => $composableBuilder(
    column: $table.ligaAvgBrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ligaMaxBrl => $composableBuilder(
    column: $table.ligaMaxBrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tcgMarketUsd => $composableBuilder(
    column: $table.tcgMarketUsd,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exchangeRateBrl => $composableBuilder(
    column: $table.exchangeRateBrl,
    builder: (column) => column,
  );
}

class $$PriceSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceSnapshotsTable,
          PriceSnapshot,
          $$PriceSnapshotsTableFilterComposer,
          $$PriceSnapshotsTableOrderingComposer,
          $$PriceSnapshotsTableAnnotationComposer,
          $$PriceSnapshotsTableCreateCompanionBuilder,
          $$PriceSnapshotsTableUpdateCompanionBuilder,
          (
            PriceSnapshot,
            BaseReferences<_$AppDatabase, $PriceSnapshotsTable, PriceSnapshot>,
          ),
          PriceSnapshot,
          PrefetchHooks Function()
        > {
  $$PriceSnapshotsTableTableManager(
    _$AppDatabase db,
    $PriceSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardApiId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> ligaMinBrl = const Value.absent(),
                Value<double?> ligaAvgBrl = const Value.absent(),
                Value<double?> ligaMaxBrl = const Value.absent(),
                Value<double?> tcgMarketUsd = const Value.absent(),
                Value<double> exchangeRateBrl = const Value.absent(),
              }) => PriceSnapshotsCompanion(
                id: id,
                cardApiId: cardApiId,
                timestamp: timestamp,
                ligaMinBrl: ligaMinBrl,
                ligaAvgBrl: ligaAvgBrl,
                ligaMaxBrl: ligaMaxBrl,
                tcgMarketUsd: tcgMarketUsd,
                exchangeRateBrl: exchangeRateBrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardApiId,
                Value<DateTime> timestamp = const Value.absent(),
                Value<double?> ligaMinBrl = const Value.absent(),
                Value<double?> ligaAvgBrl = const Value.absent(),
                Value<double?> ligaMaxBrl = const Value.absent(),
                Value<double?> tcgMarketUsd = const Value.absent(),
                Value<double> exchangeRateBrl = const Value.absent(),
              }) => PriceSnapshotsCompanion.insert(
                id: id,
                cardApiId: cardApiId,
                timestamp: timestamp,
                ligaMinBrl: ligaMinBrl,
                ligaAvgBrl: ligaAvgBrl,
                ligaMaxBrl: ligaMaxBrl,
                tcgMarketUsd: tcgMarketUsd,
                exchangeRateBrl: exchangeRateBrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceSnapshotsTable, PriceSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PriceSnapshotsTable,
                    PriceSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceSnapshotsTable,
      PriceSnapshot,
      $$PriceSnapshotsTableFilterComposer,
      $$PriceSnapshotsTableOrderingComposer,
      $$PriceSnapshotsTableAnnotationComposer,
      $$PriceSnapshotsTableCreateCompanionBuilder,
      $$PriceSnapshotsTableUpdateCompanionBuilder,
      (
        PriceSnapshot,
        BaseReferences<_$AppDatabase, $PriceSnapshotsTable, PriceSnapshot>,
      ),
      PriceSnapshot,
      PrefetchHooks Function()
    >;
typedef $$LigaPriceAlertsTableCreateCompanionBuilder =
    LigaPriceAlertsCompanion Function({
      required String id,
      required String title,
      required String targetUrl,
      Value<String> imageUrl,
      Value<String> collectionTag,
      Value<String> languageTag,
      Value<double> minTargetPrice,
      Value<double> maxTargetPrice,
      Value<bool> allowPreSale,
      Value<double?> currentLowestPrice,
      Value<String> currentStoreName,
      Value<bool> isPreSale,
      Value<bool> isAvailableInRange,
      Value<bool> isActive,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastNotifiedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LigaPriceAlertsTableUpdateCompanionBuilder =
    LigaPriceAlertsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> targetUrl,
      Value<String> imageUrl,
      Value<String> collectionTag,
      Value<String> languageTag,
      Value<double> minTargetPrice,
      Value<double> maxTargetPrice,
      Value<bool> allowPreSale,
      Value<double?> currentLowestPrice,
      Value<String> currentStoreName,
      Value<bool> isPreSale,
      Value<bool> isAvailableInRange,
      Value<bool> isActive,
      Value<DateTime?> lastCheckedAt,
      Value<DateTime?> lastNotifiedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LigaPriceAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $LigaPriceAlertsTable> {
  $$LigaPriceAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionTag => $composableBuilder(
    column: $table.collectionTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minTargetPrice => $composableBuilder(
    column: $table.minTargetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxTargetPrice => $composableBuilder(
    column: $table.maxTargetPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowPreSale => $composableBuilder(
    column: $table.allowPreSale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentLowestPrice => $composableBuilder(
    column: $table.currentLowestPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStoreName => $composableBuilder(
    column: $table.currentStoreName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreSale => $composableBuilder(
    column: $table.isPreSale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailableInRange => $composableBuilder(
    column: $table.isAvailableInRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LigaPriceAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $LigaPriceAlertsTable> {
  $$LigaPriceAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionTag => $composableBuilder(
    column: $table.collectionTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minTargetPrice => $composableBuilder(
    column: $table.minTargetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxTargetPrice => $composableBuilder(
    column: $table.maxTargetPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowPreSale => $composableBuilder(
    column: $table.allowPreSale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentLowestPrice => $composableBuilder(
    column: $table.currentLowestPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStoreName => $composableBuilder(
    column: $table.currentStoreName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreSale => $composableBuilder(
    column: $table.isPreSale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailableInRange => $composableBuilder(
    column: $table.isAvailableInRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LigaPriceAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LigaPriceAlertsTable> {
  $$LigaPriceAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get targetUrl =>
      $composableBuilder(column: $table.targetUrl, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get collectionTag => $composableBuilder(
    column: $table.collectionTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageTag => $composableBuilder(
    column: $table.languageTag,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minTargetPrice => $composableBuilder(
    column: $table.minTargetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxTargetPrice => $composableBuilder(
    column: $table.maxTargetPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowPreSale => $composableBuilder(
    column: $table.allowPreSale,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentLowestPrice => $composableBuilder(
    column: $table.currentLowestPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentStoreName => $composableBuilder(
    column: $table.currentStoreName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreSale =>
      $composableBuilder(column: $table.isPreSale, builder: (column) => column);

  GeneratedColumn<bool> get isAvailableInRange => $composableBuilder(
    column: $table.isAvailableInRange,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheckedAt => $composableBuilder(
    column: $table.lastCheckedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastNotifiedAt => $composableBuilder(
    column: $table.lastNotifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LigaPriceAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LigaPriceAlertsTable,
          LigaPriceAlert,
          $$LigaPriceAlertsTableFilterComposer,
          $$LigaPriceAlertsTableOrderingComposer,
          $$LigaPriceAlertsTableAnnotationComposer,
          $$LigaPriceAlertsTableCreateCompanionBuilder,
          $$LigaPriceAlertsTableUpdateCompanionBuilder,
          (
            LigaPriceAlert,
            BaseReferences<
              _$AppDatabase,
              $LigaPriceAlertsTable,
              LigaPriceAlert
            >,
          ),
          LigaPriceAlert,
          PrefetchHooks Function()
        > {
  $$LigaPriceAlertsTableTableManager(
    _$AppDatabase db,
    $LigaPriceAlertsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LigaPriceAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LigaPriceAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LigaPriceAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> targetUrl = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> collectionTag = const Value.absent(),
                Value<String> languageTag = const Value.absent(),
                Value<double> minTargetPrice = const Value.absent(),
                Value<double> maxTargetPrice = const Value.absent(),
                Value<bool> allowPreSale = const Value.absent(),
                Value<double?> currentLowestPrice = const Value.absent(),
                Value<String> currentStoreName = const Value.absent(),
                Value<bool> isPreSale = const Value.absent(),
                Value<bool> isAvailableInRange = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastNotifiedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LigaPriceAlertsCompanion(
                id: id,
                title: title,
                targetUrl: targetUrl,
                imageUrl: imageUrl,
                collectionTag: collectionTag,
                languageTag: languageTag,
                minTargetPrice: minTargetPrice,
                maxTargetPrice: maxTargetPrice,
                allowPreSale: allowPreSale,
                currentLowestPrice: currentLowestPrice,
                currentStoreName: currentStoreName,
                isPreSale: isPreSale,
                isAvailableInRange: isAvailableInRange,
                isActive: isActive,
                lastCheckedAt: lastCheckedAt,
                lastNotifiedAt: lastNotifiedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String targetUrl,
                Value<String> imageUrl = const Value.absent(),
                Value<String> collectionTag = const Value.absent(),
                Value<String> languageTag = const Value.absent(),
                Value<double> minTargetPrice = const Value.absent(),
                Value<double> maxTargetPrice = const Value.absent(),
                Value<bool> allowPreSale = const Value.absent(),
                Value<double?> currentLowestPrice = const Value.absent(),
                Value<String> currentStoreName = const Value.absent(),
                Value<bool> isPreSale = const Value.absent(),
                Value<bool> isAvailableInRange = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastCheckedAt = const Value.absent(),
                Value<DateTime?> lastNotifiedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LigaPriceAlertsCompanion.insert(
                id: id,
                title: title,
                targetUrl: targetUrl,
                imageUrl: imageUrl,
                collectionTag: collectionTag,
                languageTag: languageTag,
                minTargetPrice: minTargetPrice,
                maxTargetPrice: maxTargetPrice,
                allowPreSale: allowPreSale,
                currentLowestPrice: currentLowestPrice,
                currentStoreName: currentStoreName,
                isPreSale: isPreSale,
                isAvailableInRange: isAvailableInRange,
                isActive: isActive,
                lastCheckedAt: lastCheckedAt,
                lastNotifiedAt: lastNotifiedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LigaPriceAlertsTable, LigaPriceAlert>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LigaPriceAlertsTable,
                    LigaPriceAlert
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LigaPriceAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LigaPriceAlertsTable,
      LigaPriceAlert,
      $$LigaPriceAlertsTableFilterComposer,
      $$LigaPriceAlertsTableOrderingComposer,
      $$LigaPriceAlertsTableAnnotationComposer,
      $$LigaPriceAlertsTableCreateCompanionBuilder,
      $$LigaPriceAlertsTableUpdateCompanionBuilder,
      (
        LigaPriceAlert,
        BaseReferences<_$AppDatabase, $LigaPriceAlertsTable, LigaPriceAlert>,
      ),
      LigaPriceAlert,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$UserCardsTableTableManager get userCards =>
      $$UserCardsTableTableManager(_db, _db.userCards);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db, _db.wishlistItems);
  $$PriceSnapshotsTableTableManager get priceSnapshots =>
      $$PriceSnapshotsTableTableManager(_db, _db.priceSnapshots);
  $$LigaPriceAlertsTableTableManager get ligaPriceAlerts =>
      $$LigaPriceAlertsTableTableManager(_db, _db.ligaPriceAlerts);
}
