import {Button, Flex, Spin, Typography} from "antd";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {TeamCard} from "./TeamCard.tsx";
import { IconPlus } from "@tabler/icons-react";
import { useEffect, useState } from "react";
import { Team } from "../../../services/team/entities/team.ts";

export const TeamsPreviewComponent = ({ sportId }: { sportId: string }) => {
  const [page, setPage] = useState<number>(0);
  const pageSize = 5;
  const teamQuery = sportApi.useGetTeamsQuery({ id: sportId, page: page, pageSize: pageSize });
  const [teamList, setTeamList] = useState<Team[]>([]);

  useEffect(() => setTeamList([]), [sportId]);

  useEffect(() => {
      if (teamQuery.data) {
          setTeamList(prevList => prevList.concat(teamQuery.data?.elements ?? []));
      }
  }, [teamQuery.data]);

  if (teamQuery.isLoading) {
    return <Spin size={"default"} />
  }
  if (!teamQuery.data?.elements) {
    return null;
  }
  return (
    <>
      <Typography.Title level={4} style={{ marginBottom: 0 }}>Teams ({teamQuery.data?.amount})</Typography.Title>
      <Flex
        gap={10}
        wrap
      >
        {teamList.map((team) => (
          <TeamCard team={team} key={team.id} />
        ))}
        {teamList.length === 0 &&
          <Typography.Text>Keine Teams vorhanden</Typography.Text>
        }
        {
          (teamQuery.data?.amount || 0) > teamList.length &&
          <Button
            type={"text"}
            icon={<IconPlus size={20} />}
            onClick={() => {
              setPage(page + 1);
            }
            }
          >Mehr anzeigen</Button>
        }
      </Flex>
    </>
  );
}