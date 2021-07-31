CREATE OR REPLACE FUNCTION calculo_jsonb(p_userid int) 
RETURNS jsonb
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  rQuery RECORD;
BEGIN
  FOR rQuery IN SELECT SUM(roundscorebonus) roundscorebonus FROM (
				SELECT roundid::int, userid::int, max(roundscorebonus::numeric) roundscorebonus
				FROM (
				SELECT activities.userid,activities.roundid,activities.nu_peso,answers.position,answers.item_object,activities.roundscorebonus,
				answers.item_object->>'ID_USUARIO' id_usuario,
				answers.item_object->>'ID_ATIVIDADE' id_atividade,
				answers.item_object->>'DT_RESPOSTA' dt_resposta,
				answers.item_object->>'NU_PORCENTAGEM_ACERTOS' nu_porcentagem_acertos FROM (
					SELECT rounds.userid,rounds.roundid,activities.position,activities.item_object,rounds.roundscorebonus,
					activities.item_object->>'ID_USUARIO' id_usuario,
					activities.item_object->>'ID_ATIVIDADE' id_atividade,
					activities.item_object->>'NU_PESO' nu_peso,
					activities.item_object->>'answers' answers FROM (
						SELECT inf.userid,rounds.position,rounds.item_object,
						rounds.item_object->>'roundId' roundid,	
						rounds.item_object->>'name' "name",
						rounds.item_object->>'status' status,
						rounds.item_object->>'roundscorebonus' roundscorebonus,
						rounds.item_object->>'lastattemptstatus' lastattemptstatus,
						rounds.item_object->>'approved' approved,
						rounds.item_object->>'waiting' waiting,
						rounds.item_object->>'answerdate' answerdate,
						rounds.item_object->>'showstars' showstars,	
						rounds.item_object->>'showscore' showscore,		
						rounds.item_object->>'stars' stars,		
						rounds.item_object->>'activities' activities FROM (
							SELECT arr.position,arr.item_object,
							arr.item_object->>'userid' userid,
							arr.item_object->>'userstatus' userstatus,
							arr.item_object->>'maxScore' maxscore,
							arr.item_object->>'score' score,
							arr.item_object->>'image' image,
							arr.item_object->>'position' "position",
							arr.item_object->>'myRanking' myranking,
							arr.item_object->>'round' round,
							arr.item_object->>'rounds' rounds FROM 
							jsonfile2, jsonb_array_elements(info) with ordinality arr(item_object, position)) inf,
						jsonb_array_elements(inf.rounds::jsonb) with ordinality rounds(item_object, position)) rounds,
					jsonb_array_elements(rounds.activities::jsonb) with ordinality activities(item_object, position)) activities,
				jsonb_array_elements(activities.answers::jsonb) with ordinality answers(item_object, position)) r
				WHERE userid::int = p_userid
				GROUP BY roundid::int, userid::int) r
  LOOP
     RAISE NOTICE 'roundscorebonus: %',rQuery.roundscorebonus;
  END LOOP;
  RETURN json_build_object('userid',p_userid,
						   'roundscorebonus',rQuery.roundscorebonus);
END;
$BODY$;				

select calculo_jsonb(185551);