import {Alert, Button, Col, Flex, notification, Popconfirm, Row, Spin, Tag, theme, Typography} from "antd";
import {IconBuildingCommunity, IconCompass, IconListDetails, IconLogout, IconPlus, IconTrash, IconUsers} from "@tabler/icons-react";
import {useState} from "react";
import {useNavigate} from "react-router-dom";
import {ORGANISATION_PARAM} from "../sport/shared-components/useOrganisationParam.ts";
import {useDispatch} from "react-redux";
import {useUser} from "../../services/user/UserSlice.ts";
import {organisationApi} from "../../services/organisation/organisationApi.ts";
import {MyOrganisation, roleLabel} from "../../services/organisation/entities/organisation.ts";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {stringifyApiError} from "../../services/common/apiHelpers.ts";
import {CreateOrganisationModal} from "./components/CreateOrganisationModal.tsx";
import "./Organisation.css";
import {usePageMeta} from "../../utils/usePageMeta.ts";

/** one card per organisation: full width on phones, 2 / 3 / 4 per row on larger screens */
const CARD_COL = {xs: 24, sm: 12, lg: 8};

export const OrganisationsPage = () => {
    usePageMeta("Organisationen");
    const user = useUser();
    const navigate = useNavigate();
    const dispatch = useDispatch();
    const token = theme.useToken().token;
    const [api, contextHolder] = notification.useNotification();
    const [createOpen, setCreateOpen] = useState(false);

    const mine = organisationApi.useGetMineQuery(undefined, {skip: !user});
    const [leave, leaveStatus] = organisationApi.useLeaveMutation();
    const [deleteOrganisation, deleteStatus] = organisationApi.useDeleteMutation();
    const syncConfigs = syncConfigApi.useGetAllQuery(undefined, {skip: !user});
    const currentSyncConfig = useSyncConfig();

    /** Config cards may still reference a deleted organisation; reload them and refresh the selected config. */
    const refreshSyncConfigs = async () => {
        const result = await syncConfigs.refetch();
        const fresh = result.data?.find((config) => config.id === currentSyncConfig?.id);
        if (fresh) {
            dispatch(syncConfigActions.setSyncConfig(fresh));
        }
    };

    const handleLeave = async (organisation: MyOrganisation) => {
        const result = await leave(organisation.id);
        if (result.error) {
            api.error({message: "Verlassen nicht möglich", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.info({
            message: organisation.status === "PENDING" ? "Anfrage zurückgezogen" : "Organisation verlassen",
            placement: "bottomRight"
        });
        await refreshSyncConfigs();
    };

    const handleDelete = async (organisation: MyOrganisation) => {
        const result = await deleteOrganisation(organisation.id);
        if (result.error) {
            api.error({message: "Löschen nicht möglich", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.info({message: "Organisation gelöscht", description: `"${organisation.name}" wurde mit allen Gruppen und Events gelöscht.`, placement: "bottomRight"});
        await refreshSyncConfigs();
    };

    if (!user) {
        return (
            <div className="org-page">
                <Alert
                    message="Du bist noch nicht angemeldet"
                    description="Melde dich an, um deine Organisationen zu sehen oder eine Organisation zu erstellen"
                    type="warning"
                    showIcon
                />
            </div>
        );
    }

    return (
        <div className="org-page">
            {contextHolder}
            <div className="org-page-header">
                <Typography.Title level={3} style={{margin: 0}}>Meine Organisationen</Typography.Title>
                <div className="org-page-header__actions">
                    <Button icon={<IconCompass size={18}/>} onClick={() => navigate("/sport")}>
                        Organisationen entdecken
                    </Button>
                    <Button type={"primary"} icon={<IconPlus size={18}/>} onClick={() => setCreateOpen(true)}>
                        Organisation erstellen
                    </Button>
                </div>
            </div>
            <Typography.Text type={"secondary"}>
                Organisationen findest du im Sport-Tree zuoberst in der ersten Spalte. Dort siehst du die Events und kannst sie abonnieren.
            </Typography.Text>

            {mine.isLoading && <Spin size={"large"}/>}
            {mine.isError && <Alert type="error" showIcon message="Organisationen konnten nicht geladen werden" description={stringifyApiError(mine.error)}/>}

            <Row gutter={[20, 20]}>
                {mine.data?.map((organisation) => {
                    const isAdmin = organisation.role === "ADMIN";
                    const isPending = organisation.status === "PENDING";
                    return (
                        <Col key={organisation.id} {...CARD_COL}>
                            <div className="org-card" style={{background: token.colorBgBase}}>
                                <Flex gap={10} align={"center"} style={{minWidth: 0}}>
                                    <IconBuildingCommunity size={32} color={token.colorPrimary} style={{flexShrink: 0}}/>
                                    <Typography.Title level={4} style={{margin: 0, minWidth: 0}} ellipsis={{tooltip: organisation.name}}>
                                        {organisation.name}
                                    </Typography.Title>
                                </Flex>
                                <Flex gap={5} wrap>
                                    {isPending
                                        ? <Tag color={"orange"}>Anfrage ausstehend</Tag>
                                        : <Tag color={token.colorPrimary}>{roleLabel(organisation.role)}</Tag>}
                                    {!isPending && <Tag>{organisation.sport.subSports.length} Gruppen</Tag>}
                                </Flex>
                                {organisation.description &&
                                    <Typography.Paragraph style={{margin: 0}} ellipsis={{rows: 3, expandable: true, symbol: "mehr"}}>
                                        {organisation.description}
                                    </Typography.Paragraph>}
                                {isPending &&
                                    <Typography.Text type={"secondary"}>
                                        Ein Admin muss deine Anfrage freigeben, bevor du die Events siehst.
                                    </Typography.Text>}
                                <Flex gap={10} wrap style={{marginTop: "auto"}}>
                                    {!isPending &&
                                        <Button icon={<IconListDetails size={18}/>}
                                                onClick={() => navigate(`/sport?${ORGANISATION_PARAM}=${organisation.id}`)}>
                                            Events
                                        </Button>}
                                    {!isPending &&
                                        <Button icon={<IconUsers size={18}/>}
                                                onClick={() => navigate(`/organisationen/${organisation.id}/mitglieder`)}>
                                            Mitglieder
                                        </Button>}
                                    <Popconfirm
                                        title={isPending ? "Anfrage zurückziehen?" : `"${organisation.name}" verlassen?`}
                                        description={!isPending && isAdmin ? "Der letzte Admin kann die Organisation nicht verlassen." : undefined}
                                        okText={isPending ? "Zurückziehen" : "Verlassen"}
                                        cancelText="Abbrechen"
                                        onConfirm={() => handleLeave(organisation)}
                                    >
                                        <Button icon={<IconLogout size={18}/>} loading={leaveStatus.isLoading}>
                                            {isPending ? "Zurückziehen" : "Verlassen"}
                                        </Button>
                                    </Popconfirm>
                                    {isAdmin && !isPending &&
                                        <Popconfirm
                                            title={`"${organisation.name}" löschen?`}
                                            description="Alle Gruppen, Events und Mitgliedschaften werden gelöscht."
                                            okText="Löschen"
                                            okButtonProps={{danger: true}}
                                            cancelText="Abbrechen"
                                            onConfirm={() => handleDelete(organisation)}
                                        >
                                            <Button danger icon={<IconTrash size={18}/>} loading={deleteStatus.isLoading}>
                                                Löschen
                                            </Button>
                                        </Popconfirm>}
                                </Flex>
                            </div>
                        </Col>
                    );
                })}

                <Col {...CARD_COL}>
                    <div className="org-card org-card--create"
                         role="button"
                         tabIndex={0}
                         onClick={() => setCreateOpen(true)}
                         onKeyDown={(e) => {
                             if (e.key === "Enter" || e.key === " ") setCreateOpen(true);
                         }}
                         style={{border: `2px dashed ${token.colorPrimary}`, color: token.colorPrimary}}>
                        <IconPlus size={40}/>
                        <Typography.Text strong style={{color: token.colorPrimary}}>Organisation erstellen</Typography.Text>
                    </div>
                </Col>
            </Row>

            <CreateOrganisationModal open={createOpen} onClose={() => setCreateOpen(false)}/>
        </div>
    );
};
