import {Button, Col, Flex, Row, theme, Typography} from "antd";
import "./SportDetailComponent.css";
import {IconCalendarPlus, IconPlus} from "@tabler/icons-react";
import {SportEvent} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";
import {sportApi} from "../../services/sport/sportApi.ts";
import {useEffect, useState} from "react";
import {useUser} from "../../services/user/UserSlice.ts";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigDtoMapper} from "../../services/syncConfig/helpers/syncConfigHelper.ts";
import { useDispatch } from "react-redux";

export const SportDetailComponent = ({id, title}: { id: string, title: string }) => {
    const token = theme.useToken().token;
    const [page, setPage] = useState<number>(0);
    const pageSize = 5;
    const eventQuery = id ? sportApi.useGetEventsQuery({ id: id, page: page, pageSize: pageSize }) : { data: null };
    const [eventList, setEventList] = useState<SportEvent[]>([]);
    const user = useUser();
    const syncConfig = useSyncConfig();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();
    const dispatch = useDispatch();

    useEffect(() => {
        setEventList([]);
    }, [id]);

    useEffect(() => {
        if (eventQuery.data) {
            setEventList(eventList.concat(eventQuery.data.elements));
        }
    }, [eventQuery.data]);

    if (!id) {
        return (
            <Flex
                vertical
                className="tree-content"
                style={{
                    justifyContent: "start",
                    alignItems: "center",
                    paddingTop: "20px",
                }}
            >
                <Typography.Title level={2}
                    style={{ textAlign: "center", color: token.colorPrimary }}
                >Herzlich Willkommen bei Synci</Typography.Title>
                <Typography.Text>
                    Wähle eine Kategorie aus, um mehr zu erfahren.
                </Typography.Text>
            </Flex>
        );
    }

    return (
        <Flex
            vertical
            gap={40}
            className="tree-content"
            style={{
                background: "white",
                borderRadius: "0 20px 20px 0",
                padding: "20px",
            }}
        > <Flex
            justify={"space-between"}
        >
            <Flex
                vertical
                className={"tree-content-title"}
            >
                <Typography.Title level={2} className={"tree-content-main-title"}
                                  style={{color: token.colorPrimary}}>{title}</Typography.Title>
            </Flex>
                <Button
                    type={"primary"}
                    icon={<IconCalendarPlus size={20}/>}
                    disabled={!user}
                    onClick={async () => {
                        if (!syncConfig || !syncConfig.id) {
                            return;
                        }
                        const dto = syncConfigDtoMapper(syncConfig);
                        dto.sports = [...(dto.sports ?? []), id];
                        const newSyncConfig = await updateSyncConfig(dto);
                        dispatch(syncConfigActions.setSyncConfig(newSyncConfig.data));
                    }}
                >Alle Hinzufügen</Button>
        </Flex>
            <Flex
                gap={10}
            >
                <SportsNumberComponent count={eventQuery.data?.amount || 0} description={"Anzahl der Events"} color={token.colorBgContainer}/>
            </Flex>

            <Flex
                vertical
                className={"tree-content-table"}
                gap={20}
            >
                <Typography.Title level={4} style={{marginBottom: 0}}>Eventvorschau</Typography.Title>
                {
                    eventList.map((event: SportEvent, index : number) => (
                        <Row key={index}
                             gutter={[8, 8]}
                             wrap
                             justify={"space-between"}
                             align={"middle"}
                                style={{
                                    padding: "10px",
                                    borderRadius: "10px",
                                    background: token.colorBgContainer,
                                }}
                        >
                            <Col flex="0 0 100px">
                                <Typography.Text>{convertToSwissDate(event.startsOn)}</Typography.Text>
                            </Col>
                            <Col flex="1 1 300px" >
                                <Typography.Text>{event.name}</Typography.Text>
                            </Col>
                            <Col
                                flex={"0 0 auto"}
                            >
                                <Button
                                    icon={<IconCalendarPlus size={20}/>}
                                    type={"primary"}
                                    disabled={!user}
                                    loading={updateSyncConfigStatus.isLoading}
                                    onClick={async () => {
                                        if (!syncConfig || !syncConfig.id) {
                                            return;
                                        }
                                        const dto = syncConfigDtoMapper(syncConfig);
                                        dto.events = [...(dto.events ?? []), {id: event.id, sourceId: event.sourceId}];
                                        const response = await updateSyncConfig(dto);
                                        dispatch(syncConfigActions.setSyncConfig(response.data));
                                    }}
                                ></Button>
                            </Col>
                        </Row>
                    ))
                }
                {eventList.length === 0 &&
                    <Typography.Text>Keine Events vorhanden</Typography.Text>
                }
                {
                    (eventQuery.data?.amount || 0) > eventList.length &&
                    <Button
                        type={"text"}
                        icon={<IconPlus size={20}/>}
                        onClick={() => {
                            setPage(page + 1);
                        }
                        }
                    >Mehr anzeigen</Button>
                }

            </Flex>
        </Flex>
    );
};

const SportsNumberComponent = ({count, description, color}: { count: number, description: string, color: string }) => {
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
            <Typography.Text
                style={{
                    textAlign: "center",
                }}
            >
                {description}
            </Typography.Text>
        </Flex>
    );
};