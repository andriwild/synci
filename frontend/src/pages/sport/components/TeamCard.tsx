import {Button, Flex, theme, Typography} from "antd";
import {Team} from "../../../services/team/entities/team.ts";
import {IconCalendarPlus, IconUsersGroup} from "@tabler/icons-react";

export const TeamCard = ({ team } : { team: Team }) => {
    const token = theme.useToken().token;
    return (
        <Flex
            vertical
            gap={20}
            align={"center"}
            justify={"center"}
            style={{
                    background: token.colorBgContainer,
                    borderRadius: "20px",
                    padding: "20px",
                    width: "200px"
                }}
        >
            <IconUsersGroup size={30}/>
            <Typography.Text>{team.name}</Typography.Text>
            <Button icon={<IconCalendarPlus size={20}/>} type="primary">Team Abonnieren</Button>
        </Flex>
    );
}