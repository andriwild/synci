import {Button, Empty, Flex, notification, Popconfirm, Skeleton, Tag, Typography} from "antd";
import {IconEdit, IconMapPin, IconTrash} from "@tabler/icons-react";
import {useState} from "react";
import {SportEvent} from "../../../services/event/entities/event.ts";
import {dayKey, formatDayHeading, formatTime} from "../../../services/common/dateUtil.ts";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {OrganisationEventFormModal} from "../../organisation/components/OrganisationEventFormModal.tsx";
import {SubscribeButton} from "./SubscribeButton.tsx";
import {EventResponses} from "./EventResponses.tsx";
import {GameTitle} from "../../../sharedComponents/GameTitle.tsx";
import {Subscription} from "./useSubscription.ts";

/** Events grouped by local calendar day, keeping the API order (ascending start). */
const groupByDay = (events: SportEvent[]) => {
    const groups: { key: string; heading: string; events: SportEvent[] }[] = [];
    for (const event of events) {
        const key = dayKey(event.startsOn);
        const last = groups[groups.length - 1];
        if (last && last.key === key) {
            last.events.push(event);
        } else {
            groups.push({key, heading: formatDayHeading(event.startsOn), events: [event]});
        }
    }
    return groups;
};

/**
 * Upcoming events of a tree node, one block per day. With an `organisation` rows also show
 * the group, and admins can edit or delete events.
 */
export const EventList = ({events, amount, isLoading, hasMore, loadMore, sportId, sportTitle, organisation, subscription}: {
    events: SportEvent[],
    amount: number,
    isLoading: boolean,
    hasMore: boolean,
    loadMore: () => void,
    sportId: string,
    sportTitle: string,
    organisation?: MyOrganisation,
    subscription: Subscription,
}) => {
    const [api, contextHolder] = notification.useNotification();
    const [deleteEvent, deleteStatus] = organisationApi.useDeleteEventMutation();
    const [editingEvent, setEditingEvent] = useState<SportEvent | undefined>(undefined);

    const isAdmin = organisation?.role === "ADMIN";
    const showGroup = !!organisation && organisation.sport.id === sportId;
    const sportIncluded = subscription.isSportIncluded(sportId);

    const removeEvent = async (event: SportEvent) => {
        if (!organisation) return;
        const result = await deleteEvent({organisationId: organisation.id, eventId: event.id});
        if (result.error) {
            api.error({message: "Event konnte nicht gelöscht werden", description: stringifyApiError(result.error), placement: "bottomRight"});
        } else {
            api.info({message: "Event gelöscht", placement: "bottomRight"});
        }
    };

    if (isLoading) {
        return <Skeleton active title={false} paragraph={{rows: 4}}/>;
    }

    if (events.length === 0) {
        return (
            <Empty
                image={Empty.PRESENTED_IMAGE_SIMPLE}
                description={isAdmin ? "Noch keine Events. Erfasse das erste Event für deine Organisation." : "Keine kommenden Events"}
            />
        );
    }

    const remaining = amount - events.length;

    return (
        <div className="event-list">
            {contextHolder}
            {groupByDay(events).map((group) => (
                <section key={group.key} className="event-day" aria-label={group.heading}>
                    <Typography.Text strong className="event-day__heading">{group.heading}</Typography.Text>
                    <ul className="event-day__items">
                        {group.events.map((event) => {
                            const groupLabel = showGroup && event.sportId !== sportId
                                ? organisation?.sport.subSports.find((g) => g.id === event.sportId)?.label
                                : undefined;
                            return (
                                <li key={`${event.sourceId}-${event.id}`} className="event-item">
                                    <Typography.Text className="event-item__time" type={event.endsOn ? undefined : "secondary"}>
                                        {event.endsOn ? formatTime(event.startsOn) : "ganztägig"}
                                    </Typography.Text>
                                    <div className="event-item__body">
                                        <GameTitle teams={event.teams} name={event.name}/>
                                        {(event.location || groupLabel) &&
                                            <Flex gap={8} align="center" wrap className="event-item__meta">
                                                {groupLabel && <Tag bordered={false} style={{margin: 0}}>{groupLabel}</Tag>}
                                                {event.location &&
                                                    <Typography.Text type="secondary" className="event-item__location">
                                                        <IconMapPin size={14}/> {event.location}
                                                    </Typography.Text>}
                                            </Flex>}
                                        {organisation && event.responseRequested &&
                                            <EventResponses organisation={organisation} event={event}/>}
                                    </div>
                                    <div className="event-item__actions">
                                        {isAdmin &&
                                            <>
                                                <Button type="text" icon={<IconEdit size={18}/>} aria-label="Event bearbeiten"
                                                        onClick={() => setEditingEvent(event)}/>
                                                <Popconfirm title={`"${event.name}" löschen?`} okText="Löschen" okButtonProps={{danger: true}}
                                                            cancelText="Abbrechen" onConfirm={() => removeEvent(event)}>
                                                    <Button type="text" danger icon={<IconTrash size={18}/>} aria-label="Event löschen"
                                                            loading={deleteStatus.isLoading}/>
                                                </Popconfirm>
                                            </>}
                                        <SubscribeButton
                                            variant="icon"
                                            label={event.name}
                                            included={subscription.isEventIncluded(event.id)}
                                            includedVia={sportIncluded ? sportTitle : undefined}
                                            blocker={subscription.blocker}
                                            loading={subscription.pendingKey === `event:${event.id}`}
                                            onAdd={() => subscription.addEvent(event)}
                                        />
                                    </div>
                                </li>
                            );
                        })}
                    </ul>
                </section>
            ))}
            {hasMore &&
                <Button className="list-more" onClick={loadMore}>
                    Weitere Events laden · {remaining} verbleibend
                </Button>}
            {organisation && isAdmin &&
                <OrganisationEventFormModal
                    organisation={organisation}
                    open={!!editingEvent}
                    onClose={() => setEditingEvent(undefined)}
                    event={editingEvent}
                    defaultSportId={sportId}
                />}
        </div>
    );
};
