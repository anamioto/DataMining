---- 1
-- Qual a quantidade de pacientes presente na base de dados?

SELECT count(id_paciente) 
	FROM paciente;
	
-- Quantos são homens e quantos são mulheres?

SELECT ic_sexo, count(id_paciente)
	FROM paciente
	group by ic_sexo;

--- 2
--  Qual é faixa etária dos pacientes homens e mulheres? 

select count (ic_sexo) filter (where ic_sexo = 'F') as Feminino,
	   count (ic_sexo) filter (where ic_sexo = 'M') as Masculino,
	   floor((date_part('year', current_date) - aa_nascimento::integer)) as idade
    from paciente
	where aa_nascimento similar to '%(0|9)%'
    group by idade;

-- Qual a distribuição dos quartis dentro de cada faixa?  
??


-- Qual a distribuição em cada gênero por década de vida? 

select count (ic_sexo) filter (where ic_sexo = 'F') as Feminino,
	   count (ic_sexo) filter (where ic_sexo = 'M') as Masculino,
	   floor((date_part('year', current_date) - aa_nascimento::integer)/10) || '0' as década
    from paciente
	where aa_nascimento similar to '%(0|9)%'
    group by década;

--- 3
-- Qual a maior quantidade de exames solicitados para um único paciente?

SELECT id_paciente, count(id_exame) as t_exame
	FROM exames
	group by id_paciente
	order by t_exame desc;
	
--- 4
-- Qual é a média de exames pedidos para homens e para mulheres?  

with totaldepacientes as (select ic_sexo as sexo, count(id_paciente) as total
	from paciente
	group by ic_sexo),

totaldeexames as (select p.ic_sexo as sexo, count(e.id_exame) as totale
	from paciente p
	join exames e
	on (p.id_paciente = e.id_paciente)
	group by p.ic_sexo)
	
	select tp.sexo, te.totale/tp.total as media_exames_sexo
		from totaldepacientes as tp, totaldeexames as te
		where tp.sexo = te.sexo;

--- 5
-- Quantos exames de Coronavírus (2019-nCoV) foram solicitados?  
-- (resultado menos 20: GLUCORONATO DE 3 ALFA, 17 BETA ANDROSTENEDIOL, soro)

select sum(tc.C) from (select e.de_exame, count(de_exame) as C
	from exames e
	where upper(e.de_exame) similar to '%SARS%'
	or upper(e.de_exame) similar to '%COV%'
	or upper(e.de_exame) similar to '%CORONA%'
	group by  e.de_exame) as tc;

-- Quantos deles apresentam resultado positivo?  

select count(*)
	from exames e
	where (upper(e.de_exame) similar to '%SARS%'
	or upper(e.de_exame) similar to '%COV%'
	or upper(e.de_exame) similar to '%CORONA%')
	and (upper(e.de_resultado) similar to '%REAGENTE%'
	or upper(e.de_resultado) similar to '%POSITIVO%');

--- 6 
-- Para cada idade, mostre os resultados dos exames de Coronavírus (2019- nCoV).

select count (e.de_resultado), e.de_resultado, date_part('year', current_date) - p.aa_nascimento::integer as idade
    from paciente p inner join exames e on (p.id_paciente = e.id_paciente)
	where p.aa_nascimento similar to '%(0|9)%'
	and (upper(e.de_exame) similar to '%SARS%'
	or upper(e.de_exame) similar to '%COV%'
	or upper(e.de_exame) similar to '%CORONA%') 
    group by idade, e.de_resultado;
	
--- 7
-- Qual é o desfecho para a maioria dos casos registrados?

select de_desfecho, count(de_desfecho) as C
	from desfecho
	group by de_desfecho
	order by C desc;

-- E para cada distribuição por gênero e por década de vida? 

-- Por gênero

select d.de_desfecho, 
	   count (p.ic_sexo) filter (where p.ic_sexo = 'F') as Feminino,
	   count (p.ic_sexo) filter (where p.ic_sexo = 'M') as Masculino
    from paciente p inner join desfecho d
	on (p.id_paciente = d.id_paciente)
    group by d.de_desfecho;

-- Por década de vida

seselect d.de_desfecho, count(d.de_desfecho),
	   floor((date_part('year', current_date) - p.aa_nascimento::integer)/10) || '0' as década
    from paciente p inner join desfecho d 
	on (p.id_paciente = d.id_paciente)
	where p.aa_nascimento similar to '%(0|9)%'
    group by década, d.de_desfecho
    order by década;

--- 8
--Considerando as tabelas e as consultas solicitadas anteriormente, escreva/projete uma consulta para extrair algum conhecimento da base de dados que não foi descoberto pelas consultas anteriores. Apresente uma breve justificativa do objetivo da consulta e, o por que esse objetivo é relevante.

select e.de_exame, d.de_desfecho, d.dt_atendimento, d.dt_desfecho
	from desfecho d inner join exames e
	on (d.id_paciente = e.id_paciente)
	where (upper(e.de_exame) similar to '%SARS%'
	or upper(e.de_exame) similar to '%COV%'
	or upper(e.de_exame) similar to '%CORONA%');
