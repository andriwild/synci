import {Button, Flex, Input, Spin, Typography} from "antd";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {TeamCard} from "./TeamCard.tsx";
import { IconPlus, IconSearch } from "@tabler/icons-react";
import { useEffect, useState } from "react";
import { Team } from "../../../services/team/entities/team.ts";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";

export const TeamsPreviewComponent = ({ sportId }: { sportId: string }) => {
  const screens = useBreakpoint();
  const [page, setPage] = useState<number>(0);
  const pageSize = 5;
  const [searchInput, setSearchInput] = useState<string>("");
  const [searchTerm, setSearchTerm] = useState<string>("");
  const teamQuery = sportApi.useGetTeamsQuery({ id: sportId, page: page, pageSize: pageSize, searchTerm: searchTerm || undefined });
  const [teamList, setTeamList] = useState<Team[]>([]);

  useEffect(() => {
    const timeout = setTimeout(() => setSearchTerm(searchInput), 300);
    return () => clearTimeout(timeout);
  }, [searchInput]);

  useEffect(() => {
    setTeamList([]);
    setPage(0);
  }, [sportId, searchTerm]);

  useEffect(() => {
      if (teamQuery.data) {
          setTeamList(prevList => prevList.concat(teamQuery.data?.elements ?? []));
      }
  }, [teamQuery.data]);

  const uniqueTeams = Array.from(
    new Map(teamList.map((team) => [team.id, team])).values()
  );

  const isEmpty = !teamQuery.isLoading && (teamQuery.data?.amount ?? 0) === 0;
  if (isEmpty && !searchTerm) {
    return null;
  }

  return (
    <>
      <Flex justify={"space-between"} align={"center"} wrap gap={10} style={{ width: "100%" }}>
        <Typography.Title level={4} style={{ margin: 0 }}>Teams ({teamQuery.data?.amount ?? 0})</Typography.Title>
        <Input
          allowClear
          placeholder={"Team suchen"}
          prefix={<IconSearch size={16} />}
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
          style={{ width: screens.md ? 260 : "100%" }}
        />
      </Flex>
      {teamQuery.isLoading ? (
        <Spin size={"default"} />
      ) : (
        <Flex
          gap={10}
          wrap
        >
          {uniqueTeams.map((team) => (
            <TeamCard team={team} key={team.id} />
          ))}
          {uniqueTeams.length === 0 &&
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
      )}
    </>
  );
}
