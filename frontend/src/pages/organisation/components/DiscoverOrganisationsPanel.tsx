import {Button, Flex, Input, Spin, Tag, Typography, notification, theme} from "antd";
import {IconChevronLeft, IconPlus, IconSearch, IconBuildingCommunity} from "@tabler/icons-react";
import {useEffect, useState} from "react";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {OrganisationSummary} from "../../../services/organisation/entities/organisation.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";

const PAGE_SIZE = 20;

/** Status or join control for a discovered organisation. */
export const JoinControl = ({organisation}: { organisation: OrganisationSummary }) => {
    const [requestJoin, joinStatus] = organisationApi.useRequestJoinMutation();
    const [api, contextHolder] = notification.useNotification();

    if (organisation.membershipStatus === "ACTIVE") {
        return <Tag color={"green"} style={{margin: 0}}>Mitglied</Tag>;
    }
    if (organisation.membershipStatus === "PENDING") {
        return <Tag color={"orange"} style={{margin: 0}}>Anfrage ausstehend</Tag>;
    }
    return (
        <>
            {contextHolder}
            <Button
                type={"primary"}
                loading={joinStatus.isLoading}
                onClick={async () => {
                    const result = await requestJoin(organisation.id);
                    if (result.error) {
                        api.error({message: "Anfrage fehlgeschlagen", description: stringifyApiError(result.error), placement: "bottomRight"});
                    } else {
                        api.success({message: "Beitritt angefragt", description: "Ein Admin der Organisation muss deine Anfrage freigeben.", placement: "bottomRight"});
                    }
                }}
            >
                Beitritt anfragen
            </Button>
        </>
    );
};

/**
 * "Organisationen entdecken": searchable list of all organisations with the join action,
 * rendered in the detail area of the sport tree (desktop) or full width with a back button (mobile).
 */
export const DiscoverOrganisationsPanel = ({onBack}: { onBack?: () => void }) => {
    const token = theme.useToken().token;
    const [searchTerm, setSearchTerm] = useState("");
    const [debouncedTerm, setDebouncedTerm] = useState("");
    const [limit, setLimit] = useState(PAGE_SIZE);

    useEffect(() => {
        const timer = setTimeout(() => {
            setDebouncedTerm(searchTerm.trim());
            setLimit(PAGE_SIZE);
        }, 300);
        return () => clearTimeout(timer);
    }, [searchTerm]);

    // growing page size instead of accumulating pages: a refetch after joining simply replaces the list
    const query = organisationApi.useDiscoverQuery({searchTerm: debouncedTerm || undefined, page: 0, pageSize: limit});
    const organisations = query.data?.elements ?? [];
    const total = query.data?.amount ?? 0;

    return (
        <Flex vertical gap={20} className="tree-content">
            {onBack &&
                <Button icon={<IconChevronLeft size={18}/>} onClick={onBack} style={{alignSelf: "start"}}>Zurück</Button>}
            <Flex vertical gap={5}>
                <Typography.Title level={2} className={"tree-content-main-title"} style={{color: token.colorPrimary, margin: 0}}>
                    Organisationen entdecken
                </Typography.Title>
                <Typography.Text type={"secondary"}>
                    Frage den Beitritt an. Nach der Freigabe durch einen Admin erscheint die Organisation zuoberst in der ersten Spalte
                    und du siehst ihre Events.
                </Typography.Text>
            </Flex>
            <Input
                allowClear
                size={"large"}
                placeholder="Organisation suchen"
                prefix={<IconSearch size={18}/>}
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                style={{maxWidth: 500}}
            />
            {query.isLoading && <Spin/>}
            {query.isError && <Typography.Text type={"danger"}>{stringifyApiError(query.error)}</Typography.Text>}
            {!query.isLoading && organisations.length === 0 &&
                <Typography.Text>
                    {debouncedTerm ? "Keine Organisation gefunden" : "Noch keine Organisationen vorhanden"}
                </Typography.Text>}
            <Flex vertical gap={10}>
                {organisations.map((organisation) => (
                    <Flex key={organisation.id} justify={"space-between"} align={"center"} gap={20} wrap
                          style={{padding: 15, borderRadius: 10, background: token.colorBgContainer}}>
                        <Flex gap={15} align={"center"} style={{minWidth: 0, flex: 1}}>
                            <IconBuildingCommunity size={32} color={token.colorPrimary}/>
                            <Flex vertical style={{minWidth: 0}}>
                                <Typography.Text strong>{organisation.name}</Typography.Text>
                                <Typography.Text type={"secondary"} style={{fontSize: 12}}>
                                    {organisation.memberCount} {organisation.memberCount === 1 ? "Mitglied" : "Mitglieder"}
                                </Typography.Text>
                                {organisation.description &&
                                    <Typography.Paragraph style={{margin: 0}} ellipsis={{rows: 2, expandable: true, symbol: "mehr"}}>
                                        {organisation.description}
                                    </Typography.Paragraph>}
                            </Flex>
                        </Flex>
                        <JoinControl organisation={organisation}/>
                    </Flex>
                ))}
            </Flex>
            {total > organisations.length &&
                <Button type={"text"} icon={<IconPlus size={18}/>} onClick={() => setLimit(limit + PAGE_SIZE)} style={{alignSelf: "start"}}>
                    Mehr anzeigen
                </Button>}
        </Flex>
    );
};
