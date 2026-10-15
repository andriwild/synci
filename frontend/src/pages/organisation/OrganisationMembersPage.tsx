import {Alert, Button, Flex, notification, Popconfirm, Select, Spin, Tag, theme, Tooltip, Typography} from "antd";
import {IconCheck, IconChevronLeft, IconLogout, IconUserCircle, IconUserMinus, IconX} from "@tabler/icons-react";
import {useNavigate, useParams} from "react-router-dom";
import {useUser} from "../../services/user/UserSlice.ts";
import {organisationApi} from "../../services/organisation/organisationApi.ts";
import {OrganisationMember, OrgRole, roleLabel} from "../../services/organisation/entities/organisation.ts";
import {HttpError, isHttpError, stringifyApiError} from "../../services/common/apiHelpers.ts";
import {SerializedError} from "@reduxjs/toolkit";
import "./Organisation.css";

export const OrganisationMembersPage = () => {
    const {id} = useParams<{ id: string }>();
    const user = useUser();
    const navigate = useNavigate();
    const token = theme.useToken().token;
    const [api, contextHolder] = notification.useNotification();

    const organisation = organisationApi.useGetByIdQuery(id ?? "", {skip: !user || !id});
    const members = organisationApi.useGetMembersQuery(id ?? "", {skip: !user || !id});
    const [approve, approveStatus] = organisationApi.useApproveMemberMutation();
    const [removeMember, removeStatus] = organisationApi.useRemoveMemberMutation();
    const [updateRole, roleStatus] = organisationApi.useUpdateMemberRoleMutation();
    const [leave, leaveStatus] = organisationApi.useLeaveMutation();

    const notifyResult = (result: { error?: HttpError | SerializedError }, success: string) => {
        if (result.error) {
            api.error({message: "Aktion fehlgeschlagen", description: stringifyApiError(result.error), placement: "bottomRight"});
        } else {
            api.success({message: success, placement: "bottomRight"});
        }
    };

    if (!user) {
        return (
            <div className="org-page">
                <Alert message="Du bist noch nicht angemeldet" description="Melde dich an, um die Mitglieder zu verwalten" type="warning" showIcon/>
            </div>
        );
    }
    if (organisation.isLoading || members.isLoading) {
        return <Flex justify={"center"} align={"center"} style={{width: "100%", padding: 40}}><Spin size={"large"}/></Flex>;
    }
    if (organisation.isError || !organisation.data) {
        const forbidden = isHttpError(organisation.error) && organisation.error.status === 403;
        return (
            <div className="org-page">
                <Alert
                    type="error" showIcon
                    message={forbidden ? "Kein Zugriff" : "Organisation konnte nicht geladen werden"}
                    description={forbidden ? "Nur aktive Mitglieder sehen die Mitgliederliste." : stringifyApiError(organisation.error)}
                />
                <Button icon={<IconChevronLeft size={18}/>} onClick={() => navigate("/organisationen")} style={{alignSelf: "start"}}>
                    Zurück
                </Button>
            </div>
        );
    }

    const isAdmin = organisation.data.role === "ADMIN";
    const pending = (members.data ?? []).filter((member) => member.status === "PENDING");
    const active = (members.data ?? []).filter((member) => member.status === "ACTIVE");
    const adminCount = active.filter((member) => member.role === "ADMIN").length;
    const isLastAdmin = (member: OrganisationMember) => member.role === "ADMIN" && adminCount <= 1;
    const organisationId = organisation.data.id;

    const memberRow = (member: OrganisationMember, actions: React.ReactNode) => (
        <div key={member.id} className="member-row" style={{background: token.colorBgContainer}}>
            <div className="member-row__identity">
                <IconUserCircle size={32} color={token.colorPrimary} style={{flexShrink: 0}}/>
                <Flex vertical style={{minWidth: 0, flex: 1}}>
                    <Typography.Text strong ellipsis>
                        {member.name || member.email || (member.isMe && user?.email) || "Unbekannt"}{member.isMe && " (du)"}
                    </Typography.Text>
                    {member.name && member.email && <Typography.Text type={"secondary"} ellipsis>{member.email}</Typography.Text>}
                </Flex>
            </div>
            <div className="member-row__actions">{actions}</div>
        </div>
    );

    return (
        <div className="org-page">
            {contextHolder}
            <Flex align={"center"} gap={10} wrap>
                <Button icon={<IconChevronLeft size={18}/>} onClick={() => navigate("/organisationen")}>Zurück</Button>
                <Typography.Title level={3} style={{margin: 0, minWidth: 0}} ellipsis={{tooltip: organisation.data.name}}>{organisation.data.name}</Typography.Title>
                <Tag color={token.colorPrimary}>{roleLabel(organisation.data.role)}</Tag>
            </Flex>

            {isAdmin && pending.length > 0 &&
                <Flex vertical gap={10}>
                    <Typography.Title level={4} style={{margin: 0}}>Offene Anfragen ({pending.length})</Typography.Title>
                    {pending.map((member) => memberRow(member,
                        <>
                            <Button type={"primary"} icon={<IconCheck size={18}/>} loading={approveStatus.isLoading}
                                    onClick={async () => notifyResult(await approve({organisationId, memberId: member.id}), "Mitglied freigegeben")}>
                                Freigeben
                            </Button>
                            <Button icon={<IconX size={18}/>} loading={removeStatus.isLoading}
                                    onClick={async () => notifyResult(await removeMember({organisationId, memberId: member.id}), "Anfrage abgelehnt")}>
                                Ablehnen
                            </Button>
                        </>
                    ))}
                </Flex>}

            <Flex vertical gap={10}>
                <Typography.Title level={4} style={{margin: 0}}>Mitglieder ({active.length})</Typography.Title>
                {active.map((member) => memberRow(member,
                    isAdmin
                        ? <>
                            <Tooltip title={isLastAdmin(member) ? "Der letzte Admin kann nicht herabgestuft werden" : undefined}>
                                <Select<OrgRole>
                                    value={member.role}
                                    disabled={isLastAdmin(member) || roleStatus.isLoading}
                                    style={{width: 130, maxWidth: "100%"}}
                                    options={[{value: "ADMIN", label: "Admin"}, {value: "MEMBER", label: "Mitglied"}]}
                                    onChange={async (role) => notifyResult(await updateRole({organisationId, memberId: member.id, role}), "Rolle geändert")}
                                />
                            </Tooltip>
                            {!member.isMe &&
                                <Popconfirm
                                    title={`${member.name || member.email} entfernen?`}
                                    okText="Entfernen" okButtonProps={{danger: true}} cancelText="Abbrechen"
                                    onConfirm={async () => notifyResult(await removeMember({organisationId, memberId: member.id}), "Mitglied entfernt")}
                                >
                                    <Tooltip title={isLastAdmin(member) ? "Der letzte Admin kann nicht entfernt werden" : undefined}>
                                        <Button danger icon={<IconUserMinus size={18}/>} disabled={isLastAdmin(member)} loading={removeStatus.isLoading}/>
                                    </Tooltip>
                                </Popconfirm>}
                        </>
                        : <Tag color={member.role === "ADMIN" ? token.colorPrimary : undefined}>{roleLabel(member.role)}</Tag>
                ))}
            </Flex>

            <Popconfirm
                title={`"${organisation.data.name}" verlassen?`}
                okText="Verlassen" cancelText="Abbrechen"
                onConfirm={async () => {
                    const result = await leave(organisationId);
                    notifyResult(result, "Organisation verlassen");
                    if (!result.error) navigate("/organisationen");
                }}
            >
                <Tooltip title={isAdmin && adminCount <= 1 ? "Ernenne zuerst einen weiteren Admin" : undefined}>
                    <Button icon={<IconLogout size={18}/>} disabled={isAdmin && adminCount <= 1} loading={leaveStatus.isLoading}
                            style={{alignSelf: "start"}}>
                        Organisation verlassen
                    </Button>
                </Tooltip>
            </Popconfirm>
        </div>
    );
};
