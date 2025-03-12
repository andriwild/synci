import {Flex, Spin, Typography} from "antd";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {TeamCard} from "./TeamCard.tsx";

export const TeamsPreviewComponent = ({ sportId } : { sportId: string }) => {
    const teamQuery = sportApi.useGetTeamsQuery(sportId);

    if (teamQuery.isLoading) {
        return <Spin size={"default"}/>
    }
    if (!teamQuery.data) {
        return null;
    }
    return (
        <>
        <Typography.Title level={4} style={{marginBottom: 0}}>Teams</Typography.Title>
        <Flex
            gap={10}
            wrap
        >
            {teamQuery.data.map((team) => (
                <TeamCard team={team} key={team.id}/>
            ))}
        </Flex>
        </>
    );
}