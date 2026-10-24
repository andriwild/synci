import {Typography} from "antd";
import {Team} from "../services/team/entities/team.ts";
import {TeamLogo} from "./TeamLogo.tsx";
import "./GameTitle.css";

type GameTeam = Pick<Team, "id" | "name" | "logoUrl" | "logoSrcSet">;

/** "Home (logo) : (logo) Away" for a game with two teams; otherwise just [name]. */
export const GameTitle = ({teams, name, logoSize = 24, strong = false}: {
    teams?: GameTeam[],
    name: string,
    logoSize?: number,
    strong?: boolean,
}) => {
    if (!teams || teams.length < 2) {
        return <Typography.Text strong={strong} className="game-title__name">{name}</Typography.Text>;
    }
    const [home, away] = teams;
    return (
        <span className="game-title" role="group" aria-label={`${home.name} gegen ${away.name}`}>
            <Typography.Text strong={strong} className="game-title__team game-title__team--home">{home.name}</Typography.Text>
            <TeamLogo team={home} size={logoSize}/>
            <span className="game-title__colon" aria-hidden>:</span>
            <TeamLogo team={away} size={logoSize}/>
            <Typography.Text strong={strong} className="game-title__team">{away.name}</Typography.Text>
        </span>
    );
};
