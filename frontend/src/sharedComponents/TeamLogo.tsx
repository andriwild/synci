import {ReactNode, useState} from "react";
import {Avatar, theme} from "antd";
import {Team} from "../services/team/entities/team.ts";
import "./TeamLogo.css";

/** "Chicago Bears" -> "CB", "Zug" -> "ZU" */
const initials = (name: string) => {
    const words = name.split(/\s+/).filter((w) => /\p{L}/u.test(w));
    if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
    return name.replace(/[^\p{L}\p{N}]/gu, "").slice(0, 2).toUpperCase();
};

/**
 * Round team logo. Teams without logo, or whose logo fails to load (the SwissTXT CDN answers 404 for
 * some teams), show [fallback] or, by default, the initials of the team name.
 */
export const TeamLogo = ({team, size = 36, fallback}: {
    team: Pick<Team, "name" | "logoUrl" | "logoSrcSet">,
    size?: number,
    fallback?: ReactNode,
}) => {
    const token = theme.useToken().token;
    const [failedUrl, setFailedUrl] = useState<string>();
    const logoUrl = team.logoUrl && team.logoUrl !== failedUrl ? team.logoUrl : undefined;

    if (logoUrl) {
        return (
            <Avatar
                size={size}
                className="team-logo"
                src={<img src={logoUrl} srcSet={team.logoSrcSet ?? undefined} alt="" loading="lazy"
                          onError={() => setFailedUrl(logoUrl)}/>}
            />
        );
    }
    if (fallback) return <>{fallback}</>;
    return (
        <Avatar size={size} className="team-logo team-logo--initials"
                style={{background: token.colorBgContainer, color: token.colorPrimary}}>
            {initials(team.name)}
        </Avatar>
    );
};
