import {Alert, Button, Tabs, theme, Tooltip, Typography} from "antd";
import "./SportDetailComponent.css";
import {IconCalendarPlus, IconCheck, IconChevronLeft} from "@tabler/icons-react";
import {useEffect, useState} from "react";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {useSportEvents} from "./useSportEvents.ts";
import {useSportTeams} from "./useSportTeams.ts";
import {useSubscription} from "./useSubscription.ts";
import {EventList} from "./EventList.tsx";
import {TeamsPanel} from "./TeamsPanel.tsx";
import {OrganisationAdminToolbar} from "../../organisation/components/OrganisationAdminToolbar.tsx";

const plural = (count: number, one: string, many: string) => `${count} ${count === 1 ? one : many}`;

const BLOCKER_HINT = {
    "login": "Melde dich an, um Events, Teams oder ganze Sportarten zu abonnieren.",
    "no-config": "Erstelle zuerst ein Abo, damit du Einträge hinzufügen kannst.",
} as const;

/**
 * Detail panel of a tree node, shared by the desktop column tree and the mobile accordion.
 *
 * Hierarchy: breadcrumb → title → counts → one primary action, then the content in tabs
 * (Events first, Teams only when the node has teams). `onBack` renders a back button (mobile).
 * For an organisation node (root or group) admins get the tools to manage groups and events.
 */
export const SportDetailComponent = ({id, title, breadcrumb = [], organisation, onBack}: {
    id: string,
    title: string,
    /** labels of the parent nodes, e.g. ["Eishockey"] */
    breadcrumb?: string[],
    organisation?: MyOrganisation,
    onBack?: () => void
}) => {
    const token = theme.useToken().token;
    const subscription = useSubscription();
    const events = useSportEvents(id);
    const teams = useSportTeams(id, !organisation);
    // teams first: most people subscribe to their team rather than a whole league
    const [tab, setTab] = useState("teams");

    useEffect(() => {
        setTab("teams");
    }, [id]);

    if (!id) {
        return (
            <div className="tree-content tree-content--welcome">
                <Typography.Title level={2} style={{textAlign: "center", color: token.colorPrimary}}>
                    Herzlich Willkommen bei Synci
                </Typography.Title>
                <Typography.Text>Wähle eine Kategorie aus, um mehr zu erfahren.</Typography.Text>
            </div>
        );
    }

    const sportIncluded = subscription.isSportIncluded(id);
    const hasTeams = !organisation && (teams.amount > 0 || teams.searchTerm !== "");
    const meta = [
        plural(events.amount, "kommendes Event", "kommende Events"),
        ...(hasTeams && !teams.searchTerm ? [plural(teams.amount, "Team", "Teams")] : []),
    ].join(" · ");

    const eventList = (
        <EventList
            events={events.events}
            amount={events.amount}
            isLoading={events.isLoading}
            hasMore={events.hasMore}
            loadMore={events.loadMore}
            sportId={id}
            sportTitle={title}
            organisation={organisation}
            subscription={subscription}
        />
    );

    return (
        <div className="tree-content sport-detail">
            {subscription.contextHolder}
            <header className="detail-header">
                {onBack &&
                    <Button type="text" className="detail-header__back" onClick={onBack} icon={<IconChevronLeft size={18}/>}>
                        Zurück
                    </Button>}
                {breadcrumb.length > 0 &&
                    <Typography.Text type="secondary" className="detail-header__breadcrumb">
                        {breadcrumb.join(" › ")}
                    </Typography.Text>}
                <div className="detail-header__main">
                    <div className="detail-header__title">
                        <Typography.Title level={2} className="tree-content-main-title" style={{color: token.colorPrimary}}>
                            {title}
                        </Typography.Title>
                        <Typography.Text type="secondary" className="detail-header__meta">{meta}</Typography.Text>
                    </div>
                    {sportIncluded
                        ? <Tooltip title="Alle Events dieser Kategorie sind in deinem Abo">
                            <span className="detail-header__included" style={{color: token.colorSuccess}}>
                                <IconCheck size={18}/> Im Abo
                            </span>
                        </Tooltip>
                        : <Button
                            className="detail-header__action"
                            type="primary"
                            icon={<IconCalendarPlus size={18}/>}
                            disabled={!!subscription.blocker}
                            loading={subscription.pendingKey === `sport:${id}`}
                            onClick={() => subscription.addSport(id, title)}
                        >
                            Alles abonnieren
                        </Button>}
                </div>
                {organisation && <OrganisationAdminToolbar organisation={organisation} sportId={id}/>}
            </header>

            {subscription.blocker &&
                <Alert type="info" showIcon message={BLOCKER_HINT[subscription.blocker]} className="detail-hint"/>}

            {hasTeams
                ? <Tabs
                    activeKey={tab}
                    onChange={setTab}
                    className="detail-tabs"
                    items={[
                        {
                            key: "teams",
                            label: <TabLabel text="Teams" count={teams.searchTerm ? undefined : teams.amount}/>,
                            children: <TeamsPanel teams={teams} sportId={id} sportTitle={title} subscription={subscription}/>,
                        },
                        {key: "events", label: <TabLabel text="Events" count={events.amount}/>, children: eventList},
                    ]}
                />
                : <section aria-label="Events">
                    <Typography.Title level={4} className="detail-section-title">Kommende Events</Typography.Title>
                    {eventList}
                </section>}
        </div>
    );
};

const TabLabel = ({text, count}: { text: string, count?: number }) => (
    <span className="detail-tab-label">
        {text}
        {count !== undefined && <span className="detail-tab-label__count">{count}</span>}
    </span>
);
