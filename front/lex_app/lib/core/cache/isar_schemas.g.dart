// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_schemas.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedDashboardCollection on Isar {
  IsarCollection<CachedDashboard> get cachedDashboards => this.collection();
}

const CachedDashboardSchema = CollectionSchema(
  name: r'CachedDashboard',
  id: -5136382384826887534,
  properties: {
    r'cachedAt': PropertySchema(
      id: 0,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'homeDataJson': PropertySchema(
      id: 1,
      name: r'homeDataJson',
      type: IsarType.string,
    ),
    r'performanceJson': PropertySchema(
      id: 2,
      name: r'performanceJson',
      type: IsarType.string,
    ),
    r'revisionCardsJson': PropertySchema(
      id: 3,
      name: r'revisionCardsJson',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedDashboardEstimateSize,
  serialize: _cachedDashboardSerialize,
  deserialize: _cachedDashboardDeserialize,
  deserializeProp: _cachedDashboardDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _cachedDashboardGetId,
  getLinks: _cachedDashboardGetLinks,
  attach: _cachedDashboardAttach,
  version: '3.1.0+1',
);

int _cachedDashboardEstimateSize(
  CachedDashboard object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.homeDataJson.length * 3;
  bytesCount += 3 + object.performanceJson.length * 3;
  bytesCount += 3 + object.revisionCardsJson.length * 3;
  return bytesCount;
}

void _cachedDashboardSerialize(
  CachedDashboard object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.cachedAt);
  writer.writeString(offsets[1], object.homeDataJson);
  writer.writeString(offsets[2], object.performanceJson);
  writer.writeString(offsets[3], object.revisionCardsJson);
}

CachedDashboard _cachedDashboardDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedDashboard();
  object.cachedAt = reader.readDateTime(offsets[0]);
  object.homeDataJson = reader.readString(offsets[1]);
  object.id = id;
  object.performanceJson = reader.readString(offsets[2]);
  object.revisionCardsJson = reader.readString(offsets[3]);
  return object;
}

P _cachedDashboardDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedDashboardGetId(CachedDashboard object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedDashboardGetLinks(CachedDashboard object) {
  return [];
}

void _cachedDashboardAttach(
    IsarCollection<dynamic> col, Id id, CachedDashboard object) {
  object.id = id;
}

extension CachedDashboardQueryWhereSort
    on QueryBuilder<CachedDashboard, CachedDashboard, QWhere> {
  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedDashboardQueryWhere
    on QueryBuilder<CachedDashboard, CachedDashboard, QWhereClause> {
  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedDashboardQueryFilter
    on QueryBuilder<CachedDashboard, CachedDashboard, QFilterCondition> {
  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'homeDataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'homeDataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'homeDataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'homeDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      homeDataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'homeDataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performanceJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'performanceJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'performanceJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performanceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      performanceJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'performanceJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'revisionCardsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'revisionCardsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'revisionCardsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'revisionCardsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterFilterCondition>
      revisionCardsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'revisionCardsJson',
        value: '',
      ));
    });
  }
}

extension CachedDashboardQueryObject
    on QueryBuilder<CachedDashboard, CachedDashboard, QFilterCondition> {}

extension CachedDashboardQueryLinks
    on QueryBuilder<CachedDashboard, CachedDashboard, QFilterCondition> {}

extension CachedDashboardQuerySortBy
    on QueryBuilder<CachedDashboard, CachedDashboard, QSortBy> {
  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByHomeDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDataJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByHomeDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDataJson', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByPerformanceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performanceJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByPerformanceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performanceJson', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByRevisionCardsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCardsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      sortByRevisionCardsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCardsJson', Sort.desc);
    });
  }
}

extension CachedDashboardQuerySortThenBy
    on QueryBuilder<CachedDashboard, CachedDashboard, QSortThenBy> {
  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByHomeDataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDataJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByHomeDataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homeDataJson', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByPerformanceJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performanceJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByPerformanceJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performanceJson', Sort.desc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByRevisionCardsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCardsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QAfterSortBy>
      thenByRevisionCardsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revisionCardsJson', Sort.desc);
    });
  }
}

extension CachedDashboardQueryWhereDistinct
    on QueryBuilder<CachedDashboard, CachedDashboard, QDistinct> {
  QueryBuilder<CachedDashboard, CachedDashboard, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QDistinct>
      distinctByHomeDataJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homeDataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QDistinct>
      distinctByPerformanceJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performanceJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedDashboard, CachedDashboard, QDistinct>
      distinctByRevisionCardsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revisionCardsJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension CachedDashboardQueryProperty
    on QueryBuilder<CachedDashboard, CachedDashboard, QQueryProperty> {
  QueryBuilder<CachedDashboard, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedDashboard, DateTime, QQueryOperations> cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<CachedDashboard, String, QQueryOperations>
      homeDataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homeDataJson');
    });
  }

  QueryBuilder<CachedDashboard, String, QQueryOperations>
      performanceJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performanceJson');
    });
  }

  QueryBuilder<CachedDashboard, String, QQueryOperations>
      revisionCardsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revisionCardsJson');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedTopicListCollection on Isar {
  IsarCollection<CachedTopicList> get cachedTopicLists => this.collection();
}

const CachedTopicListSchema = CollectionSchema(
  name: r'CachedTopicList',
  id: 5540128601029895465,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'cachedAt': PropertySchema(
      id: 1,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'topicsJson': PropertySchema(
      id: 2,
      name: r'topicsJson',
      type: IsarType.string,
    )
  },
  estimateSize: _cachedTopicListEstimateSize,
  serialize: _cachedTopicListSerialize,
  deserialize: _cachedTopicListDeserialize,
  deserializeProp: _cachedTopicListDeserializeProp,
  idName: r'id',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedTopicListGetId,
  getLinks: _cachedTopicListGetLinks,
  attach: _cachedTopicListAttach,
  version: '3.1.0+1',
);

int _cachedTopicListEstimateSize(
  CachedTopicList object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.topicsJson.length * 3;
  return bytesCount;
}

void _cachedTopicListSerialize(
  CachedTopicList object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeDateTime(offsets[1], object.cachedAt);
  writer.writeString(offsets[2], object.topicsJson);
}

CachedTopicList _cachedTopicListDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedTopicList();
  object.cacheKey = reader.readString(offsets[0]);
  object.cachedAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.topicsJson = reader.readString(offsets[2]);
  return object;
}

P _cachedTopicListDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedTopicListGetId(CachedTopicList object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedTopicListGetLinks(CachedTopicList object) {
  return [];
}

void _cachedTopicListAttach(
    IsarCollection<dynamic> col, Id id, CachedTopicList object) {
  object.id = id;
}

extension CachedTopicListByIndex on IsarCollection<CachedTopicList> {
  Future<CachedTopicList?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  CachedTopicList? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<CachedTopicList?>> getAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<CachedTopicList?> getAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(CachedTopicList object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(CachedTopicList object, {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<CachedTopicList> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(List<CachedTopicList> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension CachedTopicListQueryWhereSort
    on QueryBuilder<CachedTopicList, CachedTopicList, QWhere> {
  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedTopicListQueryWhere
    on QueryBuilder<CachedTopicList, CachedTopicList, QWhereClause> {
  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause>
      cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterWhereClause>
      cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CachedTopicListQueryFilter
    on QueryBuilder<CachedTopicList, CachedTopicList, QFilterCondition> {
  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topicsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topicsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topicsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topicsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterFilterCondition>
      topicsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topicsJson',
        value: '',
      ));
    });
  }
}

extension CachedTopicListQueryObject
    on QueryBuilder<CachedTopicList, CachedTopicList, QFilterCondition> {}

extension CachedTopicListQueryLinks
    on QueryBuilder<CachedTopicList, CachedTopicList, QFilterCondition> {}

extension CachedTopicListQuerySortBy
    on QueryBuilder<CachedTopicList, CachedTopicList, QSortBy> {
  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByTopicsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      sortByTopicsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.desc);
    });
  }
}

extension CachedTopicListQuerySortThenBy
    on QueryBuilder<CachedTopicList, CachedTopicList, QSortThenBy> {
  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByTopicsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QAfterSortBy>
      thenByTopicsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topicsJson', Sort.desc);
    });
  }
}

extension CachedTopicListQueryWhereDistinct
    on QueryBuilder<CachedTopicList, CachedTopicList, QDistinct> {
  QueryBuilder<CachedTopicList, CachedTopicList, QDistinct> distinctByCacheKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<CachedTopicList, CachedTopicList, QDistinct>
      distinctByTopicsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topicsJson', caseSensitive: caseSensitive);
    });
  }
}

extension CachedTopicListQueryProperty
    on QueryBuilder<CachedTopicList, CachedTopicList, QQueryProperty> {
  QueryBuilder<CachedTopicList, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedTopicList, String, QQueryOperations> cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<CachedTopicList, DateTime, QQueryOperations> cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<CachedTopicList, String, QQueryOperations> topicsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topicsJson');
    });
  }
}
