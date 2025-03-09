import {Button, Col, Flex, Row, theme, Typography} from "antd";
import "./SportDetailComponent.css";
import {IconCalendarPlus, IconPlus} from "@tabler/icons-react";
import {SportEvent} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";
import {sportApi} from "../../services/sport/sportApi.ts";
import {useEffect, useState} from "react";
import {useUser} from "../../services/user/UserSlice.ts";

export const SportDetailComponent = ({id, title}: { id: string, title: string }) => {
    const token = theme.useToken().token;
    const [page, setPage] = useState<number>(0);

    const eventQuery = sportApi.useGetEventsQuery({id: id, page: page, pageSize: 5});
    const [eventList, setEventList] = useState<SportEvent[]>([]);

    const user = useUser();

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
                <Typography.Title level={2}>Herzlich Willkommen bei Synci</Typography.Title>
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
                onClick={() => {
                    //TODO eventApi.addEvent(id);
                }
                }
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
                    eventList.map((event: SportEvent) => (
                        <Row key={event.id}
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
                                    onClick={() => {
                                        //TODO eventApi.addEvent(id);
                                        console.log("Add Event", event.id);
                                    }}
                                ></Button>
                            </Col>
                        </Row>
                    ))
                }
                <Button
                    type={"text"}
                    icon={<IconPlus size={20}/>}
                    onClick={() => {
                        setPage(page + 1);
                    }
                    }
                >mehr anzeigen</Button>

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