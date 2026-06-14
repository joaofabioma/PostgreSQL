# Este backup é feito do cluster inteiro, todos os databases disponiveis, toda a pasta "data" da instalação do PostgreSQL

### comandos executados, testados em ambiente windows com PostgreSQL 18 => `PostgreSQL 18.4 on x86_64-windows, compiled by msvc-19.44.35226, 64-bit`

## gerar backup no arquivo base.tar salvando os WAL necessários
## Compressao LZ4


```bash
pg_basebackup -h localhost -U postgres -p 5432 -D basebackup/ -P -Ft -X fetch
```

## gerar arquivo com compressão LZ4

```bash
lz4 -z -c -v -5 basebackup/base.tar > basebackup/base.tar.lz4
```

## Descomprimir arquivo lz4

```bash
lz4 -d basebackup/base.tar.lz4
```
ou
```bash
lz4 -d basebackup/base.tar.lz4 basebackup/base.tar
```

## Descomprimir arquivo tar para uso na pasta data do PostgreSQL

```bash
tar -xf basebackup/base.tar -C basebackup/data
```

## Gerar backup e Comprimir arquivo base.tar com compressão LZ4

```bash
pg_basebackup -h localhost -U postgres -p 5432 -D - -Ft -X fetch | lz4 -z -v -3 > basebackup/base.tar.lz4
```

# Este é o backup de uma base especifica

## Gerar dump no formato tar

```bash
set PGPASSWORD=postgres
pg_dump -h localhost -U postgres -p 5432 -Ft cnpjgov > dumpbackup/cnpjgov.tar
```

## Gerar dump no formato Custom com compressão LZ4 mostrando progresso

```bash
set PGPASSWORD=postgres
pg_dump -h localhost -U postgres -p 5432 -Fc -Z5 cnpjgov | lz4 -z -3 -v -c > dumpbackup/cnpjgov.tar.lz4
```

## Comprimir dump de formato tar usando 7zip fragmentando em partes de 150MB

```bash
7z a -v150m -mx=5 dumpbackup/dump_cnpjgov.7z dumpbackup/cnpjgov.tar.lz4
```

## Dump de base especifica com compressao LZ4 e fragmetado usando 7z em partes de 150MB
`Existe um erro do 7z, como arquivo nao existe para usar dessa forma, o ideal seria usar o split`
```bash
set PGPASSWORD=postgres
pg_dump -h localhost -U postgres -p 5432 -Fc -Z5 cnpjgov | lz4 -z -3 -v -c | 7z a -si -v150m -mx=5 dumpbackup/dump_cnpjgov.7z
```

# Dump de base especifica com compressao LZ4 fragmentado usando split em partes de 150MB
```bash
set PGPASSWORD=postgres
pg_dump -h localhost -U postgres -p 5432 -Fc -Z5 cnpjgov |  lz4 -z -3 -v -c | split -b 150m - dumpbackup/dump_cnpjgov.tar.lz4.part-
```
