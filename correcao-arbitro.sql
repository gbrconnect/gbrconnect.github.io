-- =====================================================================
-- GBR CONNECT — correção das permissões do árbitro
-- Rode este bloco inteiro no SQL Editor do Supabase.
--
-- Por quê: quando o árbitro encerra uma partida, o sistema não mexe só
-- naquela linha. Ele avança o vencedor, manda o perdedor para a
-- repescagem, libera o próximo jogo e, se for a final, encerra o
-- torneio e grava os pontos do ranking. A regra anterior era estreita
-- demais e barrava esses efeitos.
--
-- O que continua valendo: o árbitro nunca cria nem apaga partidas,
-- não enxerga outro organizador, e não mexe em atletas, duplas,
-- arenas nem em acessos.
-- =====================================================================

-- 1) PARTIDAS: pode alterar as do próprio organizador
drop policy if exists partidas_arbitro on public.matches;
create policy partidas_arbitro on public.matches for update to authenticated
  using (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  )
  with check (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  );

-- 2) TORNEIOS: pode alterar (marcar "em andamento", encerrar e gravar a
--    classificação final) — mas não criar nem apagar
drop policy if exists torneios_arbitro on public.tournaments;
create policy torneios_arbitro on public.tournaments for update to authenticated
  using (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  )
  with check (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  );

-- 3) RANKING: pode gravar e refazer os pontos do torneio que encerrou
drop policy if exists pontos_arbitro_ins on public.ranking_points;
create policy pontos_arbitro_ins on public.ranking_points for insert to authenticated
  with check (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  );

drop policy if exists pontos_arbitro_del on public.ranking_points;
create policy pontos_arbitro_del on public.ranking_points for delete to authenticated
  using (
    public.meu_papel() = 'arbitro'
    and organization_id = public.minha_org()
  );

-- 4) Conferência: lista as regras que valem para as partidas
select policyname, cmd
from pg_policies
where schemaname = 'public' and tablename in ('matches', 'tournaments', 'ranking_points')
order by tablename, policyname;
