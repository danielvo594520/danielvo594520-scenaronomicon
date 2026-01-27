// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SystemsTable extends Systems with TableInfo<$SystemsTable, System> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SystemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'systems';
  @override
  VerificationContext validateIntegrity(Insertable<System> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  System map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return System(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SystemsTable createAlias(String alias) {
    return $SystemsTable(attachedDatabase, alias);
  }
}

class System extends DataClass implements Insertable<System> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const System(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SystemsCompanion toCompanion(bool nullToAbsent) {
    return SystemsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory System.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return System(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  System copyWith(
          {int? id, String? name, DateTime? createdAt, DateTime? updatedAt}) =>
      System(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  System copyWithCompanion(SystemsCompanion data) {
    return System(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('System(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is System &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SystemsCompanion extends UpdateCompanion<System> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SystemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SystemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<System> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SystemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return SystemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SystemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, color, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag(
      {required this.id,
      required this.name,
      required this.color,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith(
          {int? id,
          String? name,
          String? color,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String color,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : name = Value(name),
        color = Value(color),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScenariosTable extends Scenarios
    with TableInfo<$ScenariosTable, Scenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _systemIdMeta =
      const VerificationMeta('systemId');
  @override
  late final GeneratedColumn<int> systemId = GeneratedColumn<int>(
      'system_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES systems (id)'));
  static const VerificationMeta _minPlayersMeta =
      const VerificationMeta('minPlayers');
  @override
  late final GeneratedColumn<int> minPlayers = GeneratedColumn<int>(
      'min_players', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _maxPlayersMeta =
      const VerificationMeta('maxPlayers');
  @override
  late final GeneratedColumn<int> maxPlayers = GeneratedColumn<int>(
      'max_players', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _playTimeMinutesMeta =
      const VerificationMeta('playTimeMinutes');
  @override
  late final GeneratedColumn<int> playTimeMinutes = GeneratedColumn<int>(
      'play_time_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _purchaseUrlMeta =
      const VerificationMeta('purchaseUrl');
  @override
  late final GeneratedColumn<String> purchaseUrl = GeneratedColumn<String>(
      'purchase_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        systemId,
        minPlayers,
        maxPlayers,
        playTimeMinutes,
        status,
        purchaseUrl,
        thumbnailPath,
        memo,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios';
  @override
  VerificationContext validateIntegrity(Insertable<Scenario> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('system_id')) {
      context.handle(_systemIdMeta,
          systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta));
    }
    if (data.containsKey('min_players')) {
      context.handle(
          _minPlayersMeta,
          minPlayers.isAcceptableOrUnknown(
              data['min_players']!, _minPlayersMeta));
    }
    if (data.containsKey('max_players')) {
      context.handle(
          _maxPlayersMeta,
          maxPlayers.isAcceptableOrUnknown(
              data['max_players']!, _maxPlayersMeta));
    }
    if (data.containsKey('play_time_minutes')) {
      context.handle(
          _playTimeMinutesMeta,
          playTimeMinutes.isAcceptableOrUnknown(
              data['play_time_minutes']!, _playTimeMinutesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('purchase_url')) {
      context.handle(
          _purchaseUrlMeta,
          purchaseUrl.isAcceptableOrUnknown(
              data['purchase_url']!, _purchaseUrlMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scenario(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      systemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}system_id']),
      minPlayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}min_players'])!,
      maxPlayers: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_players'])!,
      playTimeMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}play_time_minutes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      purchaseUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purchase_url']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ScenariosTable createAlias(String alias) {
    return $ScenariosTable(attachedDatabase, alias);
  }
}

class Scenario extends DataClass implements Insertable<Scenario> {
  final int id;
  final String title;
  final int? systemId;
  final int minPlayers;
  final int maxPlayers;
  final int? playTimeMinutes;
  final String status;
  final String? purchaseUrl;
  final String? thumbnailPath;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Scenario(
      {required this.id,
      required this.title,
      this.systemId,
      required this.minPlayers,
      required this.maxPlayers,
      this.playTimeMinutes,
      required this.status,
      this.purchaseUrl,
      this.thumbnailPath,
      this.memo,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || systemId != null) {
      map['system_id'] = Variable<int>(systemId);
    }
    map['min_players'] = Variable<int>(minPlayers);
    map['max_players'] = Variable<int>(maxPlayers);
    if (!nullToAbsent || playTimeMinutes != null) {
      map['play_time_minutes'] = Variable<int>(playTimeMinutes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || purchaseUrl != null) {
      map['purchase_url'] = Variable<String>(purchaseUrl);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScenariosCompanion toCompanion(bool nullToAbsent) {
    return ScenariosCompanion(
      id: Value(id),
      title: Value(title),
      systemId: systemId == null && nullToAbsent
          ? const Value.absent()
          : Value(systemId),
      minPlayers: Value(minPlayers),
      maxPlayers: Value(maxPlayers),
      playTimeMinutes: playTimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(playTimeMinutes),
      status: Value(status),
      purchaseUrl: purchaseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseUrl),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Scenario.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scenario(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      systemId: serializer.fromJson<int?>(json['systemId']),
      minPlayers: serializer.fromJson<int>(json['minPlayers']),
      maxPlayers: serializer.fromJson<int>(json['maxPlayers']),
      playTimeMinutes: serializer.fromJson<int?>(json['playTimeMinutes']),
      status: serializer.fromJson<String>(json['status']),
      purchaseUrl: serializer.fromJson<String?>(json['purchaseUrl']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'systemId': serializer.toJson<int?>(systemId),
      'minPlayers': serializer.toJson<int>(minPlayers),
      'maxPlayers': serializer.toJson<int>(maxPlayers),
      'playTimeMinutes': serializer.toJson<int?>(playTimeMinutes),
      'status': serializer.toJson<String>(status),
      'purchaseUrl': serializer.toJson<String?>(purchaseUrl),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Scenario copyWith(
          {int? id,
          String? title,
          Value<int?> systemId = const Value.absent(),
          int? minPlayers,
          int? maxPlayers,
          Value<int?> playTimeMinutes = const Value.absent(),
          String? status,
          Value<String?> purchaseUrl = const Value.absent(),
          Value<String?> thumbnailPath = const Value.absent(),
          Value<String?> memo = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Scenario(
        id: id ?? this.id,
        title: title ?? this.title,
        systemId: systemId.present ? systemId.value : this.systemId,
        minPlayers: minPlayers ?? this.minPlayers,
        maxPlayers: maxPlayers ?? this.maxPlayers,
        playTimeMinutes: playTimeMinutes.present
            ? playTimeMinutes.value
            : this.playTimeMinutes,
        status: status ?? this.status,
        purchaseUrl: purchaseUrl.present ? purchaseUrl.value : this.purchaseUrl,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        memo: memo.present ? memo.value : this.memo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Scenario copyWithCompanion(ScenariosCompanion data) {
    return Scenario(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      systemId: data.systemId.present ? data.systemId.value : this.systemId,
      minPlayers:
          data.minPlayers.present ? data.minPlayers.value : this.minPlayers,
      maxPlayers:
          data.maxPlayers.present ? data.maxPlayers.value : this.maxPlayers,
      playTimeMinutes: data.playTimeMinutes.present
          ? data.playTimeMinutes.value
          : this.playTimeMinutes,
      status: data.status.present ? data.status.value : this.status,
      purchaseUrl:
          data.purchaseUrl.present ? data.purchaseUrl.value : this.purchaseUrl,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scenario(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('systemId: $systemId, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('playTimeMinutes: $playTimeMinutes, ')
          ..write('status: $status, ')
          ..write('purchaseUrl: $purchaseUrl, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      systemId,
      minPlayers,
      maxPlayers,
      playTimeMinutes,
      status,
      purchaseUrl,
      thumbnailPath,
      memo,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scenario &&
          other.id == this.id &&
          other.title == this.title &&
          other.systemId == this.systemId &&
          other.minPlayers == this.minPlayers &&
          other.maxPlayers == this.maxPlayers &&
          other.playTimeMinutes == this.playTimeMinutes &&
          other.status == this.status &&
          other.purchaseUrl == this.purchaseUrl &&
          other.thumbnailPath == this.thumbnailPath &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ScenariosCompanion extends UpdateCompanion<Scenario> {
  final Value<int> id;
  final Value<String> title;
  final Value<int?> systemId;
  final Value<int> minPlayers;
  final Value<int> maxPlayers;
  final Value<int?> playTimeMinutes;
  final Value<String> status;
  final Value<String?> purchaseUrl;
  final Value<String?> thumbnailPath;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ScenariosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.systemId = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.playTimeMinutes = const Value.absent(),
    this.status = const Value.absent(),
    this.purchaseUrl = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ScenariosCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.systemId = const Value.absent(),
    this.minPlayers = const Value.absent(),
    this.maxPlayers = const Value.absent(),
    this.playTimeMinutes = const Value.absent(),
    required String status,
    this.purchaseUrl = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.memo = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : title = Value(title),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Scenario> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? systemId,
    Expression<int>? minPlayers,
    Expression<int>? maxPlayers,
    Expression<int>? playTimeMinutes,
    Expression<String>? status,
    Expression<String>? purchaseUrl,
    Expression<String>? thumbnailPath,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (systemId != null) 'system_id': systemId,
      if (minPlayers != null) 'min_players': minPlayers,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (playTimeMinutes != null) 'play_time_minutes': playTimeMinutes,
      if (status != null) 'status': status,
      if (purchaseUrl != null) 'purchase_url': purchaseUrl,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ScenariosCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int?>? systemId,
      Value<int>? minPlayers,
      Value<int>? maxPlayers,
      Value<int?>? playTimeMinutes,
      Value<String>? status,
      Value<String?>? purchaseUrl,
      Value<String?>? thumbnailPath,
      Value<String?>? memo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ScenariosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      systemId: systemId ?? this.systemId,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      playTimeMinutes: playTimeMinutes ?? this.playTimeMinutes,
      status: status ?? this.status,
      purchaseUrl: purchaseUrl ?? this.purchaseUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<int>(systemId.value);
    }
    if (minPlayers.present) {
      map['min_players'] = Variable<int>(minPlayers.value);
    }
    if (maxPlayers.present) {
      map['max_players'] = Variable<int>(maxPlayers.value);
    }
    if (playTimeMinutes.present) {
      map['play_time_minutes'] = Variable<int>(playTimeMinutes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (purchaseUrl.present) {
      map['purchase_url'] = Variable<String>(purchaseUrl.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('systemId: $systemId, ')
          ..write('minPlayers: $minPlayers, ')
          ..write('maxPlayers: $maxPlayers, ')
          ..write('playTimeMinutes: $playTimeMinutes, ')
          ..write('status: $status, ')
          ..write('purchaseUrl: $purchaseUrl, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ScenarioTagsTable extends ScenarioTags
    with TableInfo<$ScenarioTagsTable, ScenarioTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenarioTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scenarioIdMeta =
      const VerificationMeta('scenarioId');
  @override
  late final GeneratedColumn<int> scenarioId = GeneratedColumn<int>(
      'scenario_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES scenarios (id)'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tags (id)'));
  @override
  List<GeneratedColumn> get $columns => [scenarioId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenario_tags';
  @override
  VerificationContext validateIntegrity(Insertable<ScenarioTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scenario_id')) {
      context.handle(
          _scenarioIdMeta,
          scenarioId.isAcceptableOrUnknown(
              data['scenario_id']!, _scenarioIdMeta));
    } else if (isInserting) {
      context.missing(_scenarioIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scenarioId, tagId};
  @override
  ScenarioTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScenarioTag(
      scenarioId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scenario_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $ScenarioTagsTable createAlias(String alias) {
    return $ScenarioTagsTable(attachedDatabase, alias);
  }
}

class ScenarioTag extends DataClass implements Insertable<ScenarioTag> {
  final int scenarioId;
  final int tagId;
  const ScenarioTag({required this.scenarioId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scenario_id'] = Variable<int>(scenarioId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  ScenarioTagsCompanion toCompanion(bool nullToAbsent) {
    return ScenarioTagsCompanion(
      scenarioId: Value(scenarioId),
      tagId: Value(tagId),
    );
  }

  factory ScenarioTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScenarioTag(
      scenarioId: serializer.fromJson<int>(json['scenarioId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scenarioId': serializer.toJson<int>(scenarioId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  ScenarioTag copyWith({int? scenarioId, int? tagId}) => ScenarioTag(
        scenarioId: scenarioId ?? this.scenarioId,
        tagId: tagId ?? this.tagId,
      );
  ScenarioTag copyWithCompanion(ScenarioTagsCompanion data) {
    return ScenarioTag(
      scenarioId:
          data.scenarioId.present ? data.scenarioId.value : this.scenarioId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScenarioTag(')
          ..write('scenarioId: $scenarioId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(scenarioId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScenarioTag &&
          other.scenarioId == this.scenarioId &&
          other.tagId == this.tagId);
}

class ScenarioTagsCompanion extends UpdateCompanion<ScenarioTag> {
  final Value<int> scenarioId;
  final Value<int> tagId;
  final Value<int> rowid;
  const ScenarioTagsCompanion({
    this.scenarioId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenarioTagsCompanion.insert({
    required int scenarioId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : scenarioId = Value(scenarioId),
        tagId = Value(tagId);
  static Insertable<ScenarioTag> custom({
    Expression<int>? scenarioId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenarioTagsCompanion copyWith(
      {Value<int>? scenarioId, Value<int>? tagId, Value<int>? rowid}) {
    return ScenarioTagsCompanion(
      scenarioId: scenarioId ?? this.scenarioId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scenarioId.present) {
      map['scenario_id'] = Variable<int>(scenarioId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenarioTagsCompanion(')
          ..write('scenarioId: $scenarioId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SystemsTable systems = $SystemsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ScenariosTable scenarios = $ScenariosTable(this);
  late final $ScenarioTagsTable scenarioTags = $ScenarioTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [systems, tags, scenarios, scenarioTags];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$SystemsTableCreateCompanionBuilder = SystemsCompanion Function({
  Value<int> id,
  required String name,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$SystemsTableUpdateCompanionBuilder = SystemsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$SystemsTableReferences
    extends BaseReferences<_$AppDatabase, $SystemsTable, System> {
  $$SystemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScenariosTable, List<Scenario>>
      _scenariosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.scenarios,
              aliasName:
                  $_aliasNameGenerator(db.systems.id, db.scenarios.systemId));

  $$ScenariosTableProcessedTableManager get scenariosRefs {
    final manager = $$ScenariosTableTableManager($_db, $_db.scenarios)
        .filter((f) => f.systemId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_scenariosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SystemsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SystemsTable> {
  $$SystemsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter scenariosRefs(
      ComposableFilter Function($$ScenariosTableFilterComposer f) f) {
    final $$ScenariosTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.scenarios,
        getReferencedColumn: (t) => t.systemId,
        builder: (joinBuilder, parentComposers) =>
            $$ScenariosTableFilterComposer(ComposerState(
                $state.db, $state.db.scenarios, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$SystemsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SystemsTable> {
  $$SystemsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$SystemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SystemsTable,
    System,
    $$SystemsTableFilterComposer,
    $$SystemsTableOrderingComposer,
    $$SystemsTableCreateCompanionBuilder,
    $$SystemsTableUpdateCompanionBuilder,
    (System, $$SystemsTableReferences),
    System,
    PrefetchHooks Function({bool scenariosRefs})> {
  $$SystemsTableTableManager(_$AppDatabase db, $SystemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SystemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SystemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SystemsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              SystemsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SystemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({scenariosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scenariosRefs) db.scenarios],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scenariosRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SystemsTableReferences._scenariosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SystemsTableReferences(db, table, p0)
                                .scenariosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.systemId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SystemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SystemsTable,
    System,
    $$SystemsTableFilterComposer,
    $$SystemsTableOrderingComposer,
    $$SystemsTableCreateCompanionBuilder,
    $$SystemsTableUpdateCompanionBuilder,
    (System, $$SystemsTableReferences),
    System,
    PrefetchHooks Function({bool scenariosRefs})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  required String color,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScenarioTagsTable, List<ScenarioTag>>
      _scenarioTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.scenarioTags,
          aliasName: $_aliasNameGenerator(db.tags.id, db.scenarioTags.tagId));

  $$ScenarioTagsTableProcessedTableManager get scenarioTagsRefs {
    final manager = $$ScenarioTagsTableTableManager($_db, $_db.scenarioTags)
        .filter((f) => f.tagId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_scenarioTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter scenarioTagsRefs(
      ComposableFilter Function($$ScenarioTagsTableFilterComposer f) f) {
    final $$ScenarioTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.scenarioTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder, parentComposers) =>
            $$ScenarioTagsTableFilterComposer(ComposerState($state.db,
                $state.db.scenarioTags, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool scenarioTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String color,
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({scenarioTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scenarioTagsRefs) db.scenarioTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scenarioTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._scenarioTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0)
                                .scenarioTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool scenarioTagsRefs})>;
typedef $$ScenariosTableCreateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  required String title,
  Value<int?> systemId,
  Value<int> minPlayers,
  Value<int> maxPlayers,
  Value<int?> playTimeMinutes,
  required String status,
  Value<String?> purchaseUrl,
  Value<String?> thumbnailPath,
  Value<String?> memo,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$ScenariosTableUpdateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<int?> systemId,
  Value<int> minPlayers,
  Value<int> maxPlayers,
  Value<int?> playTimeMinutes,
  Value<String> status,
  Value<String?> purchaseUrl,
  Value<String?> thumbnailPath,
  Value<String?> memo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$ScenariosTableReferences
    extends BaseReferences<_$AppDatabase, $ScenariosTable, Scenario> {
  $$ScenariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SystemsTable _systemIdTable(_$AppDatabase db) => db.systems
      .createAlias($_aliasNameGenerator(db.scenarios.systemId, db.systems.id));

  $$SystemsTableProcessedTableManager? get systemId {
    if ($_item.systemId == null) return null;
    final manager = $$SystemsTableTableManager($_db, $_db.systems)
        .filter((f) => f.id($_item.systemId!));
    final item = $_typedResult.readTableOrNull(_systemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ScenarioTagsTable, List<ScenarioTag>>
      _scenarioTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.scenarioTags,
              aliasName: $_aliasNameGenerator(
                  db.scenarios.id, db.scenarioTags.scenarioId));

  $$ScenarioTagsTableProcessedTableManager get scenarioTagsRefs {
    final manager = $$ScenarioTagsTableTableManager($_db, $_db.scenarioTags)
        .filter((f) => f.scenarioId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_scenarioTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ScenariosTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get minPlayers => $state.composableBuilder(
      column: $state.table.minPlayers,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get maxPlayers => $state.composableBuilder(
      column: $state.table.maxPlayers,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get playTimeMinutes => $state.composableBuilder(
      column: $state.table.playTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get purchaseUrl => $state.composableBuilder(
      column: $state.table.purchaseUrl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get thumbnailPath => $state.composableBuilder(
      column: $state.table.thumbnailPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get memo => $state.composableBuilder(
      column: $state.table.memo,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$SystemsTableFilterComposer get systemId {
    final $$SystemsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.systemId,
        referencedTable: $state.db.systems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$SystemsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.systems, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter scenarioTagsRefs(
      ComposableFilter Function($$ScenarioTagsTableFilterComposer f) f) {
    final $$ScenarioTagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.scenarioTags,
        getReferencedColumn: (t) => t.scenarioId,
        builder: (joinBuilder, parentComposers) =>
            $$ScenarioTagsTableFilterComposer(ComposerState($state.db,
                $state.db.scenarioTags, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ScenariosTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get minPlayers => $state.composableBuilder(
      column: $state.table.minPlayers,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get maxPlayers => $state.composableBuilder(
      column: $state.table.maxPlayers,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get playTimeMinutes => $state.composableBuilder(
      column: $state.table.playTimeMinutes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get status => $state.composableBuilder(
      column: $state.table.status,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get purchaseUrl => $state.composableBuilder(
      column: $state.table.purchaseUrl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get thumbnailPath => $state.composableBuilder(
      column: $state.table.thumbnailPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get memo => $state.composableBuilder(
      column: $state.table.memo,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$SystemsTableOrderingComposer get systemId {
    final $$SystemsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.systemId,
        referencedTable: $state.db.systems,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$SystemsTableOrderingComposer(ComposerState(
                $state.db, $state.db.systems, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ScenariosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScenariosTable,
    Scenario,
    $$ScenariosTableFilterComposer,
    $$ScenariosTableOrderingComposer,
    $$ScenariosTableCreateCompanionBuilder,
    $$ScenariosTableUpdateCompanionBuilder,
    (Scenario, $$ScenariosTableReferences),
    Scenario,
    PrefetchHooks Function({bool systemId, bool scenarioTagsRefs})> {
  $$ScenariosTableTableManager(_$AppDatabase db, $ScenariosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ScenariosTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ScenariosTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int?> systemId = const Value.absent(),
            Value<int> minPlayers = const Value.absent(),
            Value<int> maxPlayers = const Value.absent(),
            Value<int?> playTimeMinutes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> purchaseUrl = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ScenariosCompanion(
            id: id,
            title: title,
            systemId: systemId,
            minPlayers: minPlayers,
            maxPlayers: maxPlayers,
            playTimeMinutes: playTimeMinutes,
            status: status,
            purchaseUrl: purchaseUrl,
            thumbnailPath: thumbnailPath,
            memo: memo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<int?> systemId = const Value.absent(),
            Value<int> minPlayers = const Value.absent(),
            Value<int> maxPlayers = const Value.absent(),
            Value<int?> playTimeMinutes = const Value.absent(),
            required String status,
            Value<String?> purchaseUrl = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
          }) =>
              ScenariosCompanion.insert(
            id: id,
            title: title,
            systemId: systemId,
            minPlayers: minPlayers,
            maxPlayers: maxPlayers,
            playTimeMinutes: playTimeMinutes,
            status: status,
            purchaseUrl: purchaseUrl,
            thumbnailPath: thumbnailPath,
            memo: memo,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScenariosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {systemId = false, scenarioTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (scenarioTagsRefs) db.scenarioTags],
              addJoins: <
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
                      dynamic>>(state) {
                if (systemId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.systemId,
                    referencedTable:
                        $$ScenariosTableReferences._systemIdTable(db),
                    referencedColumn:
                        $$ScenariosTableReferences._systemIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (scenarioTagsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ScenariosTableReferences
                            ._scenarioTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ScenariosTableReferences(db, table, p0)
                                .scenarioTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.scenarioId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ScenariosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScenariosTable,
    Scenario,
    $$ScenariosTableFilterComposer,
    $$ScenariosTableOrderingComposer,
    $$ScenariosTableCreateCompanionBuilder,
    $$ScenariosTableUpdateCompanionBuilder,
    (Scenario, $$ScenariosTableReferences),
    Scenario,
    PrefetchHooks Function({bool systemId, bool scenarioTagsRefs})>;
typedef $$ScenarioTagsTableCreateCompanionBuilder = ScenarioTagsCompanion
    Function({
  required int scenarioId,
  required int tagId,
  Value<int> rowid,
});
typedef $$ScenarioTagsTableUpdateCompanionBuilder = ScenarioTagsCompanion
    Function({
  Value<int> scenarioId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$ScenarioTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ScenarioTagsTable, ScenarioTag> {
  $$ScenarioTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ScenariosTable _scenarioIdTable(_$AppDatabase db) =>
      db.scenarios.createAlias(
          $_aliasNameGenerator(db.scenarioTags.scenarioId, db.scenarios.id));

  $$ScenariosTableProcessedTableManager? get scenarioId {
    if ($_item.scenarioId == null) return null;
    final manager = $$ScenariosTableTableManager($_db, $_db.scenarios)
        .filter((f) => f.id($_item.scenarioId!));
    final item = $_typedResult.readTableOrNull(_scenarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.scenarioTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager? get tagId {
    if ($_item.tagId == null) return null;
    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id($_item.tagId!));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScenarioTagsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ScenarioTagsTable> {
  $$ScenarioTagsTableFilterComposer(super.$state);
  $$ScenariosTableFilterComposer get scenarioId {
    final $$ScenariosTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scenarioId,
        referencedTable: $state.db.scenarios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ScenariosTableFilterComposer(ComposerState(
                $state.db, $state.db.scenarios, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ScenarioTagsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ScenarioTagsTable> {
  $$ScenarioTagsTableOrderingComposer(super.$state);
  $$ScenariosTableOrderingComposer get scenarioId {
    final $$ScenariosTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.scenarioId,
        referencedTable: $state.db.scenarios,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ScenariosTableOrderingComposer(ComposerState(
                $state.db, $state.db.scenarios, joinBuilder, parentComposers)));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $state.db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$TagsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.tags, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$ScenarioTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScenarioTagsTable,
    ScenarioTag,
    $$ScenarioTagsTableFilterComposer,
    $$ScenarioTagsTableOrderingComposer,
    $$ScenarioTagsTableCreateCompanionBuilder,
    $$ScenarioTagsTableUpdateCompanionBuilder,
    (ScenarioTag, $$ScenarioTagsTableReferences),
    ScenarioTag,
    PrefetchHooks Function({bool scenarioId, bool tagId})> {
  $$ScenarioTagsTableTableManager(_$AppDatabase db, $ScenarioTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ScenarioTagsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ScenarioTagsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> scenarioId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScenarioTagsCompanion(
            scenarioId: scenarioId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int scenarioId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScenarioTagsCompanion.insert(
            scenarioId: scenarioId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScenarioTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({scenarioId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (scenarioId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.scenarioId,
                    referencedTable:
                        $$ScenarioTagsTableReferences._scenarioIdTable(db),
                    referencedColumn:
                        $$ScenarioTagsTableReferences._scenarioIdTable(db).id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$ScenarioTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$ScenarioTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScenarioTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScenarioTagsTable,
    ScenarioTag,
    $$ScenarioTagsTableFilterComposer,
    $$ScenarioTagsTableOrderingComposer,
    $$ScenarioTagsTableCreateCompanionBuilder,
    $$ScenarioTagsTableUpdateCompanionBuilder,
    (ScenarioTag, $$ScenarioTagsTableReferences),
    ScenarioTag,
    PrefetchHooks Function({bool scenarioId, bool tagId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SystemsTableTableManager get systems =>
      $$SystemsTableTableManager(_db, _db.systems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ScenariosTableTableManager get scenarios =>
      $$ScenariosTableTableManager(_db, _db.scenarios);
  $$ScenarioTagsTableTableManager get scenarioTags =>
      $$ScenarioTagsTableTableManager(_db, _db.scenarioTags);
}
