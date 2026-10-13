import {Button, Flex, theme, Typography} from "antd";
import "./SportDetailComponent.css";
import {IconCalendarPlus, IconChevronLeft} from "@tabler/icons-react";
import {useDispatch} from "react-redux";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi.ts";
import {useUser} from "../../../services/user/UserSlice.ts";
import {syncConfigDtoMapper} from "../../../services/syncConfig/helpers/syncConfigHelper.ts";
import {TeamsPreviewComponent} from "./TeamsPreviewComponent.tsx";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {useSportEvents} from "./useSportEvents.ts";
import {track} from "../../../utils/analytics.ts";
import {EventRows} from "./EventRows.tsx";
import {OrganisationAdminToolbar} from "../../organisation/components/OrganisationAdminToolbar.tsx";

/**
 * Detail panel of a tree node, shared by the desktop column tree and the mobile accordion.
 * `onBack` renders a back button (mobile). For an organisation node (root or group) `organisation`
 * is set: the teams preview is hidden and admins get the tools to manage groups and events.
 */
export const SportDetailComponent = ({id, title, organisation, onBack}: {
    id: string,
    title: string,
    organisation?: MyOrganisation,
    onBack?: () => void
}) => {
    const token = theme.useToken().token;
    const user = useUser();
    const syncConfig = useSyncConfig();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const dispatch = useDispatch();
    const {events, amount, hasMore, loadMore} = useSportEvents(id);

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

    const alreadyIncluded = !!syncConfig?.sports?.some((sport) => sport.id === id);

    const addAll = async () => {
        if (!syncConfig || !syncConfig.id) {
            return;
        }
        const dto = syncConfigDtoMapper(syncConfig);
        dto.sports = [...(dto.sports ?? []), id];
        const newSyncConfig = await updateSyncConfig(dto);
        if (newSyncConfig.data) {
            track("subscription-add", {type: "sport", name: title});
            dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
        }
    };

    return (
        <div className="tree-content">
            <div className="detail-header">
                {onBack &&
                    <Button className="detail-header__back" onClick={onBack} icon={<IconChevronLeft size={20}/>}>Zurück</Button>}
                <Flex vertical gap={5} className="detail-header__title">
                    <Typography.Title level={2} className={"tree-content-main-title"}
                                      style={{color: token.colorPrimary, margin: 0}}>{title}</Typography.Title>
                    {organisation && <OrganisationAdminToolbar organisation={organisation} sportId={id}/>}
                </Flex>
                <Button
                    className="detail-header__action"
                    type={"primary"}
                    icon={<IconCalendarPlus size={20}/>}
                    disabled={!user || alreadyIncluded}
                    loading={updateSyncConfigStatus.isLoading}
                    onClick={addAll}
                >{alreadyIncluded ? "Im Abo" : "Alle Hinzufügen"}</Button>
            </div>
            <Flex gap={10}>
                <SportsNumberComponent count={amount} description={"Anzahl der Events"} color={token.colorBgContainer}/>
            </Flex>
            {!organisation && <TeamsPreviewComponent sportId={id}/>}
            <EventRows events={events} amount={amount} hasMore={hasMore} loadMore={loadMore} organisation={organisation} sportId={id}/>
        </div>
    );
};

export const SportsNumberComponent = ({count, description, color}: { count: number, description: string, color: string }) => {
    return (
        <Flex vertical
              flex={1}
              align={"center"}
              style={{
                  padding: "0 20px 20px 20px",
                  background: color,
                  borderRadius: "20px",
                  maxWidth: "300px",
              }}
        >
            <Typography.Title level={1}>
                {count}
            </Typography.Title>
            <Typography.Text style={{textAlign: "center"}}>
                {description}
            </Typography.Text>
        </Flex>
    );
};
