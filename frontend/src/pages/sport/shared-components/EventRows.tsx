import {Button, Flex, notification, Popconfirm, Tag, theme, Typography} from "antd";
import {IconCalendarPlus, IconEdit, IconPlus, IconTrash} from "@tabler/icons-react";
import {useState} from "react";
import {useDispatch} from "react-redux";
import {SportEvent} from "../../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../../services/common/dateUtil.ts";
import {useUser} from "../../../services/user/UserSlice.ts";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi.ts";
import {syncConfigDtoMapper} from "../../../services/syncConfig/helpers/syncConfigHelper.ts";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {OrganisationEventFormModal} from "../../organisation/components/OrganisationEventFormModal.tsx";
import {track} from "../../../utils/analytics.ts";

const formatTime = (event: SportEvent) => {
    if (!event.endsOn) return "ganztägig";
    return new Date(event.startsOn).toLocaleTimeString("de-CH", {hour: "2-digit", minute: "2-digit"});
};

/**
 * Event list shared by the desktop and mobile detail views. With an `organisation` the rows show
 * location and group, and admins can edit or delete events.
 */
export const EventRows = ({events, amount, hasMore, loadMore, organisation, sportId}: {
    events: SportEvent[],
    amount: number,
    hasMore: boolean,
    loadMore: () => void,
    organisation?: MyOrganisation,
    sportId: string
}) => {
    const token = theme.useToken().token;
    const user = useUser();
    const syncConfig = useSyncConfig();
    const dispatch = useDispatch();
    const [api, contextHolder] = notification.useNotification();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const [deleteEvent, deleteStatus] = organisationApi.useDeleteEventMutation();
    const [editingEvent, setEditingEvent] = useState<SportEvent | undefined>(undefined);

    const isAdmin = organisation?.role === "ADMIN";
    const sportIncluded = syncConfig?.sports.some((s) => s.id === sportId) ?? false;
    const eventIncluded = (event: SportEvent) => syncConfig?.events.some((e) => e.id === event.id) ?? false;
    const showGroup = !!organisation && organisation.sport.id === sportId;

    const addToConfig = async (event: SportEvent) => {
        if (!syncConfig || !syncConfig.id) return;
        const dto = syncConfigDtoMapper(syncConfig);
        dto.events = [...(dto.events ?? []), {id: event.id, sourceId: event.sourceId}];
        const response = await updateSyncConfig(dto);
        if (response.error) {
            api.error({message: "Abo konnte nicht aktualisiert werden", description: stringifyApiError(response.error), placement: "bottomRight"});
            return;
        }
        track("subscription-add", {type: "event", name: event.name, sport: event.rootSport});
        dispatch(syncConfigActions.setSyncConfig(response.data));
    };

    const removeEvent = async (event: SportEvent) => {
        if (!organisation) return;
        const result = await deleteEvent({organisationId: organisation.id, eventId: event.id});
        if (result.error) {
            api.error({message: "Event konnte nicht gelöscht werden", description: stringifyApiError(result.error), placement: "bottomRight"});
        } else {
            api.info({message: "Event gelöscht", placement: "bottomRight"});
        }
    };

    return (
        <Flex vertical className={"tree-content-table"} gap={20}>
            {contextHolder}
            <Typography.Title level={4} style={{marginBottom: 0}}>Events</Typography.Title>
            {events.map((event) => {
                const group = showGroup && event.sportId !== sportId
                    ? organisation?.sport.subSports.find((g) => g.id === event.sportId)
                    : undefined;
                return (
                    <div key={`${event.sourceId}-${event.id}`} className="event-row" style={{background: token.colorBgContainer}}>
                        <div className="event-row__date">
                            <Typography.Text>{convertToSwissDate(event.startsOn)}</Typography.Text>
                            {organisation && <Typography.Text type={"secondary"}> · {formatTime(event)}</Typography.Text>}
                        </div>
                        <div className="event-row__name">
                            <Flex vertical>
                                <Flex gap={5} align={"center"} wrap>
                                    <Typography.Text>{event.name}</Typography.Text>
                                    {group && <Tag style={{margin: 0}}>{group.label}</Tag>}
                                </Flex>
                                {event.location && <Typography.Text type={"secondary"}>{event.location}</Typography.Text>}
                            </Flex>
                        </div>
                        <div className="event-row__actions">
                                {isAdmin &&
                                    <>
                                        <Button icon={<IconEdit size={18}/>} aria-label="Event bearbeiten" onClick={() => setEditingEvent(event)}/>
                                        <Popconfirm title={`"${event.name}" löschen?`} okText="Löschen" okButtonProps={{danger: true}}
                                                    cancelText="Abbrechen" onConfirm={() => removeEvent(event)}>
                                            <Button danger icon={<IconTrash size={18}/>} aria-label="Event löschen" loading={deleteStatus.isLoading}/>
                                        </Popconfirm>
                                    </>}
                                <Button
                                    icon={<IconCalendarPlus size={20}/>}
                                    type={"primary"}
                                    aria-label="Event zum Abo hinzufügen"
                                    disabled={!user || sportIncluded || eventIncluded(event)}
                                    loading={updateSyncConfigStatus.isLoading}
                                    onClick={() => addToConfig(event)}
                                />
                        </div>
                    </div>
                );
            })}
            {events.length === 0 &&
                <Typography.Text>
                    {isAdmin ? "Noch keine Events. Erfasse das erste Event für deine Organisation." : "Keine Events vorhanden"}
                </Typography.Text>}
            {hasMore &&
                <Button type={"text"} icon={<IconPlus size={20}/>} onClick={loadMore}>
                    Mehr anzeigen ({amount - events.length} weitere)
                </Button>}
            {organisation && isAdmin &&
                <OrganisationEventFormModal
                    organisation={organisation}
                    open={!!editingEvent}
                    onClose={() => setEditingEvent(undefined)}
                    event={editingEvent}
                    defaultSportId={sportId}
                />}
        </Flex>
    );
};
