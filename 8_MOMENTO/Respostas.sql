-- Respostas simples para os exercícios da Momento.
-- Execute 0_Base.sql antes. As consultas de alteração ficam no final.
USE momento;

-- NÍVEL 1 — EMPRESA

-- 1.1 Preencha os dados pessoais antes de cadastrar. Não use dados fictícios.
-- O departamento, cargo e salário podem ser consultados nas tabelas abaixo.
SELECT departamento_id, departamento_nome FROM departamentos;
SELECT cargo_id, cargo_nome, min_salario, max_salario FROM cargos;

-- 1.2 Total de funcionários
SELECT COUNT(*) AS total_funcionarios FROM funcionarios;

-- 1.3 Funcionários de Tecnologia
SELECT COUNT(*) AS total_tecnologia
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Tecnologia da Informação';

-- 1.4 Departamentos
SELECT departamento_nome FROM departamentos ORDER BY departamento_nome;
SELECT COUNT(*) AS total_departamentos FROM departamentos;

-- 1.5 Escritórios e países
SELECT COUNT(*) AS total_escritorios FROM escritorios;
SELECT DISTINCT p.pais_nome
FROM escritorios e
JOIN paises p ON p.pais_id = e.pais_id
ORDER BY p.pais_nome;

-- NÍVEL 2 — SALÁRIOS

-- 2.1 Funcionários de Vendas
SELECT COUNT(*) AS total_vendas
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Vendas';

-- 2.2 Folha salarial de Vendas, separada por moeda
SELECT f.moeda_salario, SUM(f.salario) AS total_salarios
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Vendas'
GROUP BY f.moeda_salario;

-- 2.3 Média salarial sem CEO, CMO e CFO. Não misture moedas.
SELECT f.moeda_salario, ROUND(AVG(f.salario), 2) AS media_salarial
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
WHERE c.cargo_nome NOT IN ('CEO', 'CMO', 'CFO')
GROUP BY f.moeda_salario;

-- 2.4 Média salarial de Tecnologia, por moeda
SELECT f.moeda_salario, ROUND(AVG(f.salario), 2) AS media_salarial
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Tecnologia da Informação'
GROUP BY f.moeda_salario;

-- 2.5 Médias por departamento e moeda; compare departamentos na mesma moeda
SELECT d.departamento_nome, f.moeda_salario, ROUND(AVG(f.salario), 2) AS media_salarial
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, f.moeda_salario
ORDER BY f.moeda_salario, media_salarial DESC;

-- 2.6 Departamento com menos funcionários (inclui departamentos vazios)
SELECT d.departamento_nome, COUNT(f.funcionario_id) AS total_funcionarios
FROM departamentos d
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY d.departamento_id, d.departamento_nome
ORDER BY total_funcionarios
LIMIT 1;

-- NÍVEL 3 — RECURSOS HUMANOS

-- 3.1 Funcionários com cônjuge registrado
SELECT COUNT(DISTINCT funcionario_id) AS total_com_conjuge
FROM dependentes
WHERE relacionamento = 'Cônjuge';

-- 3.2 Funcionários com filhos registrados
SELECT COUNT(DISTINCT funcionario_id) AS total_com_filhos
FROM dependentes
WHERE relacionamento = 'Filha(o)';

-- 3.3 Contratação mais antiga
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao
LIMIT 1;

-- 3.4 Contratação mais recente
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao DESC
LIMIT 1;

-- 3.5 Cinco funcionários com mais tempo de casa
SELECT primeiro_nome, sobrenome, data_contratacao
FROM funcionarios
ORDER BY data_contratacao
LIMIT 5;

-- 3.6 Contratações na década de 1990
SELECT COUNT(*) AS contratados_anos_1990
FROM funcionarios
WHERE data_contratacao >= '1990-01-01'
  AND data_contratacao < '2000-01-01';

-- 3.7 Média salarial por ano e moeda
SELECT YEAR(data_contratacao) AS ano, moeda_salario, ROUND(AVG(salario), 2) AS media_salarial
FROM funcionarios
GROUP BY YEAR(data_contratacao), moeda_salario
ORDER BY ano, moeda_salario;

-- NÍVEL 4 — SUPRIMENTOS

-- 4.1 Custo de suprimentos por escritório e moeda
SELECT e.escritorio_nome, s.moeda,
       SUM(s.quantidade_estoque * s.custo_unitario) AS custo_total
FROM suprimentos s
JOIN escritorios e ON e.escritorio_id = s.escritorio_id
GROUP BY e.escritorio_id, e.escritorio_nome, s.moeda
ORDER BY custo_total DESC;

-- 4.2 Escritório com mais tipos de suprimento
SELECT e.escritorio_nome, COUNT(DISTINCT s.suprimento_nome) AS tipos
FROM escritorios e
JOIN suprimentos s ON s.escritorio_id = e.escritorio_id
GROUP BY e.escritorio_id, e.escritorio_nome
ORDER BY tipos DESC
LIMIT 1;

-- 4.3 Suprimento com maior custo unitário (comparável por moeda)
SELECT suprimento_nome, custo_unitario, moeda
FROM suprimentos
ORDER BY custo_unitario DESC
LIMIT 1;

-- 4.4 Valor de estoque, por moeda
SELECT moeda, SUM(quantidade_estoque * custo_unitario) AS valor_inventario
FROM suprimentos
GROUP BY moeda;

-- NÍVEL 5 — PRODUTOS E VENDAS

-- 5.1 Produtos vendidos
SELECT DISTINCT p.produto_nome
FROM produtos p
JOIN itens_venda i ON i.produto_id = p.produto_id
ORDER BY p.produto_nome;

-- 5.2 Produto mais vendido por quantidade
SELECT p.produto_nome, SUM(i.quantidade) AS quantidade_vendida
FROM produtos p
JOIN itens_venda i ON i.produto_id = p.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY quantidade_vendida DESC
LIMIT 1;

-- 5.3 Produto menos vendido entre os que tiveram venda
SELECT p.produto_nome, SUM(i.quantidade) AS quantidade_vendida
FROM produtos p
JOIN itens_venda i ON i.produto_id = p.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY quantidade_vendida
LIMIT 1;

-- 5.4 Produto que gerou mais receita
SELECT p.produto_nome, SUM(i.quantidade * i.preco_unitario) AS receita
FROM produtos p
JOIN itens_venda i ON i.produto_id = p.produto_id
GROUP BY p.produto_id, p.produto_nome
ORDER BY receita DESC
LIMIT 1;

-- 5.5 Produto mais caro no catálogo
SELECT produto_nome, preco_catalogo, moeda
FROM produtos
ORDER BY preco_catalogo DESC
LIMIT 1;

-- 5.6 Faturamento total por moeda
SELECT moeda, SUM(quantidade * preco_unitario) AS faturamento
FROM itens_venda
GROUP BY moeda;

-- 5.7 Vendas em junho de 2023
SELECT COUNT(*) AS vendas_junho_2023
FROM vendas
WHERE data_venda >= '2023-06-01' AND data_venda < '2023-07-01';

-- 5.8 Vendedor com mais transações
SELECT CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS vendedor,
       COUNT(DISTINCT v.venda_id) AS total_vendas
FROM funcionarios f
JOIN vendas v ON v.funcionario_id = f.funcionario_id
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome
ORDER BY total_vendas DESC
LIMIT 1;

-- 5.9 Vendedor com maior receita
SELECT CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS vendedor,
       SUM(i.quantidade * i.preco_unitario) AS receita
FROM funcionarios f
JOIN vendas v ON v.funcionario_id = f.funcionario_id
JOIN itens_venda i ON i.venda_id = v.venda_id
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome
ORDER BY receita DESC
LIMIT 1;

-- NÍVEL 6 — CONSULTAS ANTES DAS ALTERAÇÕES

-- 6.1 Consultar o escritório de destino
SELECT escritorio_id FROM escritorios WHERE escritorio_nome = 'Wayne Offices';

-- 6.2 Conferir as pessoas de Tecnologia antes de transferir
SELECT f.funcionario_id, f.primeiro_nome, f.sobrenome, f.salario
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE d.departamento_nome = 'Tecnologia da Informação'
ORDER BY f.salario;

-- 6.6 Conferir quantos seriam afetados pela regra de aposentadoria
SELECT COUNT(*) AS contratados_antes_de_1990
FROM funcionarios
WHERE data_contratacao < '1990-01-01';

-- NÍVEL 7 — EDUCAÇÃO

-- 7.1 Cursos ativos, nível e quantidade de turmas
SELECT c.curso_nome, c.carga_horaria, n.nome AS nivel,
       COUNT(t.turma_id) AS total_turmas
FROM cursos c
JOIN niveis_curso n ON n.nivel_curso_id = c.nivel_curso_id
LEFT JOIN turmas t ON t.curso_id = c.curso_id
WHERE c.ativo = 1
GROUP BY c.curso_id, c.curso_nome, c.carga_horaria, n.nome;

-- 7.2 Turmas, professores, capacidade e matrículas
SELECT c.curso_nome, t.codigo, CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS professor,
       t.capacidade, COUNT(m.matricula_id) AS matriculas
FROM turmas t
JOIN cursos c ON c.curso_id = t.curso_id
JOIN funcionarios f ON f.funcionario_id = t.professor_funcionario_id
LEFT JOIN matriculas m ON m.turma_id = t.turma_id
GROUP BY t.turma_id, c.curso_nome, t.codigo, professor, t.capacidade;

-- 7.3 Bolsistas, percentual e curso
SELECT c.curso_nome, COUNT(DISTINCT b.aluno_id) AS alunos_com_bolsa,
       AVG(b.percentual_desconto) AS percentual_medio
FROM bolsas b
JOIN cursos c ON c.curso_id = b.curso_id
GROUP BY c.curso_id, c.curso_nome;

-- 7.4 Indicadores por curso e turma
SELECT c.curso_nome, t.codigo,
       COUNT(m.matricula_id) AS matriculas,
       SUM(CASE WHEN sm.nome = 'CONCLUIDA' THEN 1 ELSE 0 END) AS concluintes,
       SUM(CASE WHEN m.certificado_emitido = 1 THEN 1 ELSE 0 END) AS certificados,
       ROUND(AVG(m.nota_final), 2) AS nota_media
FROM cursos c
JOIN turmas t ON t.curso_id = c.curso_id
LEFT JOIN matriculas m ON m.turma_id = t.turma_id
LEFT JOIN status_matricula sm ON sm.status_matricula_id = m.status_matricula_id
GROUP BY c.curso_id, c.curso_nome, t.turma_id, t.codigo;
-- Para comparar "sucesso", também seria preciso definir critérios, período,
-- perfil dos estudantes, conclusão e contexto de cada curso.

-- 7.5 Trajetória de Ariel Nunes
SELECT a.nome, c.curso_nome, t.codigo, m.data_matricula, sm.nome AS status_matricula,
       b.percentual_desconto, tv.nome AS tipo_vinculo, v.data_inicio AS inicio_vinculo,
       f.data_contratacao
FROM alunos a
LEFT JOIN matriculas m ON m.aluno_id = a.aluno_id
LEFT JOIN turmas t ON t.turma_id = m.turma_id
LEFT JOIN cursos c ON c.curso_id = t.curso_id
LEFT JOIN status_matricula sm ON sm.status_matricula_id = m.status_matricula_id
LEFT JOIN bolsas b ON b.aluno_id = a.aluno_id AND b.curso_id = c.curso_id
LEFT JOIN vinculos_talentos v ON v.aluno_id = a.aluno_id
LEFT JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = v.tipo_vinculo_id
LEFT JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
WHERE a.nome = 'Ariel Nunes';

-- 7.6 Vínculos e totais por tipo
SELECT a.nome, tv.nome AS tipo_vinculo, d.departamento_nome, sv.nome AS status,
       CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS funcionario_associado
FROM vinculos_talentos v
JOIN alunos a ON a.aluno_id = v.aluno_id
JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = v.tipo_vinculo_id
JOIN departamentos d ON d.departamento_id = v.departamento_id
JOIN status_vinculo sv ON sv.status_vinculo_id = v.status_vinculo_id
LEFT JOIN funcionarios f ON f.funcionario_id = v.funcionario_id;

SELECT tv.nome AS tipo_vinculo, COUNT(DISTINCT v.aluno_id) AS pessoas
FROM vinculos_talentos v
JOIN tipos_vinculo tv ON tv.tipo_vinculo_id = v.tipo_vinculo_id
GROUP BY tv.nome;

-- 7.7 Departamentos que recebem talentos
SELECT DISTINCT d.departamento_nome
FROM vinculos_talentos v
JOIN departamentos d ON d.departamento_id = v.departamento_id;

-- 7.8 Indicadores em uma linha
SELECT
  (SELECT COUNT(*) FROM alunos) AS total_alunos,
  (SELECT COUNT(*) FROM matriculas m JOIN status_matricula s
   ON s.status_matricula_id = m.status_matricula_id WHERE s.nome = 'ATIVA') AS matriculas_ativas,
  (SELECT COUNT(*) FROM matriculas m JOIN status_matricula s
   ON s.status_matricula_id = m.status_matricula_id WHERE s.nome = 'CONCLUIDA') AS concluintes,
  (SELECT COUNT(*) FROM bolsas) AS bolsas_concedidas,
  (SELECT COUNT(*) FROM vinculos_talentos v JOIN tipos_vinculo t
   ON t.tipo_vinculo_id = v.tipo_vinculo_id WHERE t.nome = 'ESTAGIO') AS estagios,
  (SELECT COUNT(*) FROM vinculos_talentos v JOIN tipos_vinculo t
   ON t.tipo_vinculo_id = v.tipo_vinculo_id WHERE t.nome = 'CONTRATACAO') AS contratacoes,
  (SELECT GROUP_CONCAT(DISTINCT d.departamento_nome ORDER BY d.departamento_nome)
   FROM vinculos_talentos v JOIN departamentos d
   ON d.departamento_id = v.departamento_id) AS departamentos_com_talentos;

-- 7.11 vinculos_talentos registra estágio ou contratação de aluno
-- e permite associá-lo ao departamento e, em contratações, ao funcionário.

-- NÍVEL 8 — DUAS FRENTES

-- 8.1 Salários por departamento e suprimentos por escritório são dados separados.
-- Não há tabela de despesas gerais nem relação direta de suprimentos com departamento.
SELECT d.departamento_nome, f.moeda_salario, SUM(f.salario) AS total_salarios
FROM departamentos d
JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, f.moeda_salario;

SELECT e.escritorio_nome, s.moeda,
       SUM(s.quantidade_estoque * s.custo_unitario) AS total_suprimentos
FROM escritorios e
JOIN suprimentos s ON s.escritorio_id = e.escritorio_id
GROUP BY e.escritorio_id, e.escritorio_nome, s.moeda;

-- 8.2 Escritórios com equipes comerciais ou educacionais
SELECT e.escritorio_nome, d.educacional, COUNT(f.funcionario_id) AS funcionarios
FROM escritorios e
JOIN departamentos d ON d.escritorio_id = e.escritorio_id
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY e.escritorio_id, e.escritorio_nome, d.educacional
ORDER BY e.escritorio_nome, d.educacional;

-- 8.3 Não é possível concluir sem comparar moedas e conhecer despesas/investimentos.
-- Use o faturamento (5.6) e os custos (8.1), mantendo cada moeda separada.

-- 8.4 Cargos usados nas duas frentes
SELECT c.cargo_nome
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
JOIN departamentos d ON d.departamento_id = f.departamento_id
GROUP BY c.cargo_id, c.cargo_nome
HAVING COUNT(DISTINCT d.educacional) = 2;
-- Os departamentos são classificados como comerciais ou educacionais,
-- então um departamento não é compartilhado pelas duas frentes.

-- 8.5 Equipes e vendas por país do escritório do vendedor
SELECT p.pais_nome, d.educacional, COUNT(DISTINCT f.funcionario_id) AS funcionarios,
       COUNT(DISTINCT v.venda_id) AS vendas
FROM paises p
JOIN escritorios e ON e.pais_id = p.pais_id
JOIN departamentos d ON d.escritorio_id = e.escritorio_id
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
LEFT JOIN vendas v ON v.funcionario_id = f.funcionario_id
GROUP BY p.pais_id, p.pais_nome, d.educacional
ORDER BY p.pais_nome, d.educacional;

-- NÍVEL 9 — AGREGAÇÕES

-- 9.1 Relatório por departamento e moeda
SELECT d.departamento_nome, f.moeda_salario,
       COUNT(f.funcionario_id) AS funcionarios,
       SUM(f.salario) AS total_salarios,
       ROUND(AVG(f.salario), 2) AS media_salarial
FROM departamentos d
LEFT JOIN funcionarios f ON f.departamento_id = d.departamento_id
GROUP BY d.departamento_id, d.departamento_nome, f.moeda_salario;

-- 9.2 Três cargos mais comuns
SELECT c.cargo_nome, COUNT(*) AS funcionarios
FROM funcionarios f
JOIN cargos c ON c.cargo_id = f.cargo_id
GROUP BY c.cargo_id, c.cargo_nome
ORDER BY funcionarios DESC
LIMIT 3;

-- 9.3 Pessoas acima da média do próprio departamento e moeda
SELECT f.primeiro_nome, f.sobrenome, d.departamento_nome, f.salario, f.moeda_salario
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
WHERE f.salario > (
  SELECT AVG(f2.salario)
  FROM funcionarios f2
  WHERE f2.departamento_id = f.departamento_id
    AND f2.moeda_salario = f.moeda_salario
);

-- 9.4 Contratações por ano (a quantidade é a taxa solicitada no enunciado)
SELECT YEAR(data_contratacao) AS ano, COUNT(*) AS contratacoes
FROM funcionarios
GROUP BY YEAR(data_contratacao)
ORDER BY ano;

-- 9.5 Ranking de vendedores
SELECT CONCAT(f.primeiro_nome, ' ', f.sobrenome) AS vendedor,
       COUNT(DISTINCT v.venda_id) AS vendas,
       SUM(i.quantidade * i.preco_unitario) AS receita
FROM funcionarios f
JOIN vendas v ON v.funcionario_id = f.funcionario_id
JOIN itens_venda i ON i.venda_id = v.venda_id
GROUP BY f.funcionario_id, f.primeiro_nome, f.sobrenome
ORDER BY receita DESC;

-- 9.6 Produtos vendidos por apenas um vendedor
SELECT p.produto_nome
FROM produtos p
JOIN itens_venda i ON i.produto_id = p.produto_id
JOIN vendas v ON v.venda_id = i.venda_id
GROUP BY p.produto_id, p.produto_nome
HAVING COUNT(DISTINCT v.funcionario_id) = 1;

-- NÍVEL 10 — AUDITORIA

-- 10.1 Vendas sem vendedor (funcionario_id é obrigatório no esquema)
SELECT venda_id FROM vendas WHERE funcionario_id IS NULL;

-- 10.2 Vendedor que não existe (a chave estrangeira impede esse caso)
SELECT v.venda_id, v.funcionario_id
FROM vendas v
LEFT JOIN funcionarios f ON f.funcionario_id = v.funcionario_id
WHERE f.funcionario_id IS NULL;

-- 10.3 Diferença de preço acima de 10%, sem comparar moedas diferentes
SELECT p.produto_nome, i.moeda, MIN(i.preco_unitario) AS menor_preco,
       MAX(i.preco_unitario) AS maior_preco
FROM itens_venda i
JOIN produtos p ON p.produto_id = i.produto_id
GROUP BY p.produto_id, p.produto_nome, i.moeda
HAVING MIN(i.preco_unitario) > 0
   AND (MAX(i.preco_unitario) - MIN(i.preco_unitario)) / MIN(i.preco_unitario) > 0.10;

-- 10.4 Indicadores em uma única consulta
SELECT
  (SELECT COUNT(*) FROM funcionarios) AS total_funcionarios,
  (SELECT GROUP_CONCAT(CONCAT(moeda_salario, ': ', total) SEPARATOR '; ')
   FROM (SELECT moeda_salario, SUM(salario) AS total
         FROM funcionarios GROUP BY moeda_salario) AS salarios) AS custo_salarios_por_moeda,
  (SELECT COUNT(*) FROM departamentos) AS total_departamentos,
  (SELECT COUNT(*) FROM escritorios) AS total_escritorios,
  (SELECT GROUP_CONCAT(CONCAT(moeda, ': ', total) SEPARATOR '; ')
   FROM (SELECT moeda, SUM(quantidade * preco_unitario) AS total
         FROM itens_venda GROUP BY moeda) AS receitas) AS receita_por_moeda,
  (SELECT p.produto_nome
   FROM produtos p JOIN itens_venda i ON i.produto_id = p.produto_id
   GROUP BY p.produto_id, p.produto_nome
   ORDER BY SUM(i.quantidade) DESC LIMIT 1) AS produto_mais_vendido;

-- NÍVEL 11 — ETL DO CSV
-- Importe o CSV em stg_vendas_csv pelo Workbench (separador ;, cabeçalho ligado).
-- Não converta campos durante a importação.

SELECT COUNT(*) AS linhas_importadas FROM stg_vendas_csv;

-- SKU normalizado sem alterar o dado bruto
SELECT source_row_id, sku_raw, UPPER(TRIM(sku_raw)) AS sku_normalizado
FROM stg_vendas_csv;

-- Linhas com SKU sem correspondência
SELECT s.source_row_id, s.sku_raw
FROM stg_vendas_csv s
LEFT JOIN produtos p ON UPPER(p.sku) = UPPER(TRIM(s.sku_raw))
WHERE p.produto_id IS NULL;

-- E-mail do vendedor sem correspondência
SELECT s.source_row_id, s.email_vendedor_raw
FROM stg_vendas_csv s
LEFT JOIN funcionarios f ON LOWER(f.email) = LOWER(TRIM(s.email_vendedor_raw))
WHERE f.funcionario_id IS NULL;

-- Pedidos/itens repetidos: compare os valores antes de marcar como duplicata
SELECT pedido_ref, item_seq, COUNT(*) AS ocorrencias,
       GROUP_CONCAT(source_row_id ORDER BY source_row_id) AS linhas
FROM stg_vendas_csv
GROUP BY pedido_ref, item_seq
HAVING COUNT(*) > 1;

-- Consultar valores brutos que exigem revisão antes da carga
SELECT source_row_id, pedido_ref, data_venda_raw, locale_origem, sku_raw,
       quantidade_raw, preco_unitario_raw, moeda_raw, canal_raw, status_raw
FROM stg_vendas_csv
WHERE locale_origem = '?'
   OR moeda_raw IS NULL OR TRIM(moeda_raw) = '' OR moeda_raw NOT IN ('USD', 'BRL')
   OR quantidade_raw NOT REGEXP '^[0-9]+$'
   OR data_venda_raw = '31/02/2025'
   OR preco_unitario_raw = 'N/A';

-- Não carregue automaticamente os registros ambíguos. Exemplos no CSV:
-- source_row_id 1 e 3 parecem duplicados; 13 conflita na quantidade.
-- Moeda em branco/XYZ, locale desconhecida, SKU, vendedor ou canal inválido
-- devem ser revisados e registrados em etl_rejeicoes antes da carga final.
-- source_row_id deve acompanhar cada item aceito em itens_venda.

-- NÍVEL 12 — ALTERAÇÕES SEGURAS
-- Confira os SELECTs do nível 6. Execute como teste; troque ROLLBACK por
-- COMMIT somente depois de validar tudo. IDs de transferência: 105 e 139,
-- os dois menores salários de Tecnologia, sem contar Bruce.

START TRANSACTION;

INSERT INTO departamentos (departamento_id, departamento_nome, educacional, escritorio_id)
SELECT 31, 'Inovações', 0, escritorio_id
FROM escritorios
WHERE escritorio_nome = 'Wayne Offices';

-- O cargo já existe na tabela cargos (ID 26).
-- Bruce ganha 5.000 conforme o enunciado; depois recebe o reajuste de 10%
-- por continuar em Tecnologia.
UPDATE funcionarios
SET cargo_id = 26, salario = 5000
WHERE funcionario_id = 104;

UPDATE funcionarios
SET departamento_id = 31
WHERE funcionario_id IN (105, 139)
  AND departamento_id = 6;

UPDATE funcionarios
SET salario = salario * 1.10
WHERE departamento_id = 6;

INSERT INTO suprimentos
  (suprimento_id, referencia_compra, suprimento_nome, quantidade_estoque,
   custo_unitario, moeda, data_compra, escritorio_id)
SELECT 106, 'PO-1400-08', 'Headsets', 15, 150.00, 'USD', CURRENT_DATE, escritorio_id
FROM escritorios
WHERE escritorio_nome = 'Wayne Offices';

-- Aposentadoria sem apagar histórico
UPDATE funcionarios
SET status_funcionario_id = 3
WHERE data_contratacao < '1990-01-01';

-- Conferência antes de confirmar
SELECT f.funcionario_id, f.primeiro_nome, f.sobrenome, d.departamento_nome,
       f.salario, sf.nome AS status
FROM funcionarios f
JOIN departamentos d ON d.departamento_id = f.departamento_id
JOIN status_funcionario sf ON sf.status_funcionario_id = f.status_funcionario_id
WHERE f.funcionario_id IN (104, 105, 139)
   OR d.departamento_id = 31
   OR f.data_contratacao < '1990-01-01';

SELECT * FROM suprimentos WHERE referencia_compra = 'PO-1400-08';

ROLLBACK;
