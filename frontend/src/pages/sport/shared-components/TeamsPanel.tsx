import {Avatar, Button, Empty, Input, Skeleton, theme, Typography} from "antd";
import {IconSearch} from "@tabler/icons-react";
import {displayGender, Team} from "../../../services/team/entities/team.ts";
import {SubscribeButton} from "./SubscribeButton.tsx";
import {Subscription} from "./useSubscription.ts";
import {SportTeams} from "./useSportTeams.ts";

/** "Chicago Bears" -> "CB", "Zug" -> "ZU" */
const initials = (name: string) => {
    const words = name.split(/\s+/).filter((w) => /\p{L}/u.test(w));
    if (words.length >= 2) return (words[0][0] + words[words.length - 1][0]).toUpperCase();
    return name.replace(/[^\p{L}\p{N}]/gu, "").slice(0, 2).toUpperCase();
};

const TeamRow = ({team, sportTitle, sportIncluded, subscription}: {
    team: Team,
    sportTitle: string,
    sportIncluded: boolean,
    subscription: Subscription,
}) => {
    const token = theme.useToken().token;
    const gender = displayGender(team.gender);
    return (
        <li className="team-row">
            <Avatar size={36} style={{background: token.colorBgContainer, color: token.colorPrimary, fontWeight: 600, flexShrink: 0}}>
                {initials(team.name)}
            </Avatar>
            <div className="team-row__name">
                <Typography.Text ellipsis={{tooltip: team.name}}>{team.name}</Typography.Text>
                {gender && <Typography.Text type="secondary"> {gender}</Typography.Text>}
            </div>
            <SubscribeButton
                variant="text"
                label={team.name}
                included={subscription.isTeamIncluded(team.id)}
                includedVia={sportIncluded ? sportTitle : undefined}
                blocker={subscription.blocker}
                loading={subscription.pendingKey === `team:${team.id}`}
                onAdd={() => subscription.addTeam(team)}
            />
        </li>
    );
};

/** Searchable, compact team list; data comes from useSportTeams in the detail container. */
export const TeamsPanel = ({teams, sportId, sportTitle, subscription}: {
    teams: SportTeams,
    sportId: string,
    sportTitle: string,
    subscription: Subscription,
}) => {
    const sportIncluded = subscription.isSportIncluded(sportId);
    return (
        <div className="teams-panel">
            <Input
                allowClear
                placeholder="Team suchen"
                prefix={<IconSearch size={16}/>}
                value={teams.searchInput}
                onChange={(e) => teams.setSearchInput(e.target.value)}
                className="teams-panel__search"
            />
            {teams.isLoading
                ? <Skeleton active avatar title={false} paragraph={{rows: 3}}/>
                : teams.teams.length === 0
                    ? <Empty image={Empty.PRESENTED_IMAGE_SIMPLE}
                             description={teams.searchTerm ? `Kein Team für «${teams.searchTerm}» gefunden` : "Keine Teams vorhanden"}/>
                    : <ul className="team-list">
                        {teams.teams.map((team) => (
                            <TeamRow key={team.id} team={team} sportTitle={sportTitle} sportIncluded={sportIncluded}
                                     subscription={subscription}/>
                        ))}
                    </ul>}
            {teams.hasMore &&
                <Button className="list-more" onClick={teams.loadMore} loading={teams.isFetching}>
                    Weitere Teams laden · {teams.amount - teams.teams.length} verbleibend
                </Button>}
        </div>
    );
};
