import {Alert, Button, Flex, Modal, Select, Spin, theme, Tooltip, Typography} from "antd";
import {IconPlus, IconTrash} from "@tabler/icons-react";
import {ReactNode, useState} from "react";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {matchupApi} from "../../../services/matchup/matchupApi.ts";
import {displayGender, Team} from "../../../services/team/entities/team.ts";
import {Matchup} from "../../../services/syncConfig/entities/syncConfig.ts";
import {formatDayHeading, formatTime} from "../../../services/common/dateUtil.ts";
import {TeamLogo} from "../../../sharedComponents/TeamLogo.tsx";
import {GameTitle} from "../../../sharedComponents/GameTitle.tsx";
import {Subscription} from "./useSubscription.ts";
import {useSportTeams} from "./useSportTeams.ts";
import {TOP_EVENTS} from "./treeNodes.ts";

/** Top Events page: the matchups of the active Abo, each with its next game and a button to remove it. */
export const TopEvents = ({subscription}: { subscription: Subscription }) => {
    const token = theme.useToken().token;
    const {matchups, blocker} = subscription;

    return (
        <section className="top-events" aria-label="Top Events">
            <Typography.Text type="secondary">
                Wähle zwei Teams, und alle Spiele zwischen ihnen kommen in dein Abo, egal in welchem Wettbewerb.
            </Typography.Text>
            {matchups.length > 0
                ? <ul className="top-events__list">
                    {matchups.map((matchup) => (
                        <TopEventRow key={`${matchup.teamA.id}:${matchup.teamB.id}`} matchup={matchup} subscription={subscription}/>
                    ))}
                </ul>
                : !blocker &&
                <div className="top-events__empty" style={{background: token.colorFillAlter}}>
                    <Typography.Text type="secondary">Noch keine Top Events in diesem Abo.</Typography.Text>
                </div>}
        </section>
    );
};

/** Header action of the Top Events page; disabled once the Abo holds as many as it may. */
export const AddTopEventButton = ({subscription}: { subscription: Subscription }) => {
    const [open, setOpen] = useState(false);
    const full = subscription.matchupCount >= subscription.matchupLimit;

    return (
        <>
            <Tooltip title={full && !subscription.blocker ? "Entferne zuerst eines deiner Top Events, um ein neues hinzuzufügen." : undefined}>
                <Button
                    className="detail-header__action"
                    type="primary"
                    icon={<IconPlus size={18}/>}
                    disabled={!!subscription.blocker || full}
                    onClick={() => setOpen(true)}
                >
                    Top Event hinzufügen
                </Button>
            </Tooltip>
            {open && <CreateTopEventModal subscription={subscription} onClose={() => setOpen(false)}/>}
        </>
    );
};

/** One Top Event with its next game. */
const TopEventRow = ({matchup, subscription}: { matchup: Matchup, subscription: Subscription }) => {
    const token = theme.useToken().token;
    const games = matchupApi.useGetEventsQuery(
        {sourceId: matchup.sourceId, teamA: matchup.teamA.id, teamB: matchup.teamB.id, page: 0, pageSize: 3},
    );
    const next = games.data?.elements[0];
    const name = `${matchup.teamA.name} – ${matchup.teamB.name}`;

    return (
        <li className="top-event" style={{background: token.colorFillAlter}}>
            <div className="top-event__body">
                <GameTitle teams={[matchup.teamA, matchup.teamB]} name={name} strong/>
                <Typography.Text type="secondary" ellipsis className="top-event__next">
                    {games.isLoading ? "…"
                        : next ? `Nächstes Spiel: ${formatDayHeading(next.startsOn)}, ${formatTime(next.startsOn)}`
                            : "Zurzeit kein Spiel angesetzt"}
                </Typography.Text>
            </div>
            <Button
                type="text"
                icon={<IconTrash size={18}/>}
                aria-label={`${name} entfernen`}
                loading={subscription.pendingKey === `matchup:${matchup.teamA.id}:${matchup.teamB.id}`}
                onClick={() => subscription.removeMatchup(matchup)}
            />
        </li>
    );
};

const CreateTopEventModal = ({subscription, onClose}: { subscription: Subscription, onClose: () => void }) => {
    const sports = sportApi.useGetAllQuery();
    const sportsWithTeams = (sports.data ?? []).filter((sport) => sport.hasTeams && sport.name !== TOP_EVENTS);
    const [sportId, setSportId] = useState<string>();
    const [teamA, setTeamA] = useState<Team>();
    const [teamB, setTeamB] = useState<Team>();
    const sport = sportsWithTeams.find((s) => s.id === sportId);

    const preview = matchupApi.useGetEventsQuery(
        {sourceId: teamA?.sourceId ?? 0, teamA: teamA?.id ?? "", teamB: teamB?.id ?? "", page: 0, pageSize: 3},
        {skip: !teamA || !teamB},
    );
    const included = !!teamA && !!teamB && subscription.isMatchupIncluded(teamA, teamB);
    const full = subscription.matchupCount >= subscription.matchupLimit;

    const add = async () => {
        if (!teamA || !teamB || !sport) return;
        if (await subscription.addMatchup(teamA, teamB, sport.label)) onClose();
    };

    return (
        <Modal
            title="Top Event hinzufügen"
            open
            onCancel={onClose}
            onOk={add}
            okText="Zum Abo hinzufügen"
            cancelText="Abbrechen"
            okButtonProps={{
                disabled: !teamA || !teamB || included || full,
                loading: !!teamA && !!teamB && subscription.pendingKey === `matchup:${teamA.id}:${teamB.id}`,
            }}
        >
            <Flex vertical gap={16}>
                <Field label="Sportart">
                    <Select
                        style={{width: "100%"}}
                        placeholder="Sportart wählen"
                        loading={sports.isLoading}
                        value={sportId}
                        onChange={(id: string) => {
                            setSportId(id);
                            setTeamA(undefined);
                            setTeamB(undefined);
                        }}
                        options={sportsWithTeams.map((s) => ({value: s.id, label: s.label}))}
                    />
                </Field>
                <Field label="Team 1">
                    <TeamSelect sportId={sportId} value={teamA} onChange={setTeamA} other={teamB}/>
                </Field>
                <Field label="Team 2">
                    <TeamSelect sportId={sportId} value={teamB} onChange={setTeamB} other={teamA}/>
                </Field>

                {included && <Alert type="warning" showIcon message="Dieses Top Event ist schon in deinem Abo."/>}
                {teamA && teamB && !included && (
                    preview.isFetching
                        ? <Spin size="small"/>
                        : preview.data && preview.data.amount > 0
                            ? <div className="top-events__preview">
                                <Typography.Text strong>
                                    {preview.data.amount === 1 ? "1 Spiel geplant" : `${preview.data.amount} Spiele geplant`}
                                </Typography.Text>
                                <ul>
                                    {preview.data.elements.map((event) => (
                                        <li key={event.id}>
                                            <Typography.Text type="secondary">{formatDayHeading(event.startsOn)}, {formatTime(event.startsOn)}</Typography.Text>
                                            <GameTitle teams={event.teams} name={event.name} logoSize={20}/>
                                        </li>
                                    ))}
                                </ul>
                            </div>
                            : <Alert type="info" showIcon
                                     message="Zurzeit ist kein Spiel zwischen diesen Teams angesetzt. Neue Spiele kommen automatisch in dein Abo."/>
                )}

                <Typography.Text type="secondary">
                    {subscription.matchupCount} von {subscription.matchupLimit} Top Events genutzt
                </Typography.Text>
            </Flex>
        </Modal>
    );
};

const Field = ({label, children}: { label: string, children: ReactNode }) => (
    <Flex vertical gap={6}>
        <Typography.Text strong>{label}</Typography.Text>
        {children}
    </Flex>
);

/** Searchable team picker within one sport; the other team of the matchup is left out. */
const TeamSelect = ({sportId, value, onChange, other}: {
    sportId?: string,
    value?: Team,
    onChange: (team?: Team) => void,
    other?: Team,
}) => {
    const teams = useSportTeams(sportId ?? "", !!sportId);
    const candidates = teams.teams.filter((t) => t.id !== other?.id && (!other || t.sourceId === other.sourceId));
    const options = value && !candidates.some((t) => t.id === value.id) ? [value, ...candidates] : candidates;

    return (
        <Select
            style={{width: "100%"}}
            showSearch
            allowClear
            disabled={!sportId}
            placeholder={sportId ? "Team suchen" : "Zuerst Sportart wählen"}
            filterOption={false}
            searchValue={teams.searchInput}
            onSearch={teams.setSearchInput}
            loading={teams.isFetching}
            notFoundContent={teams.isFetching ? <Spin size="small"/> : "Kein Team gefunden"}
            value={value?.id}
            onChange={(id?: string) => {
                onChange(options.find((t) => t.id === id));
                teams.setSearchInput("");
            }}
            options={options.map((team) => ({
                value: team.id,
                label: (
                    <Flex align="center" gap={8}>
                        <TeamLogo team={team} size={20}/>
                        <span>{team.name} {displayGender(team.gender)}</span>
                    </Flex>
                ),
            }))}
        />
    );
};
