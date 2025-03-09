import {Button, Col, Flex, Row, theme, Typography} from "antd";
import "./SportDetailComponent.css";
import {IconPlus} from "@tabler/icons-react";
import {Event} from "../../services/event/entities/event.ts";
import {convertToSwissDate} from "../../services/common/dateUtil.ts";

export const SportDetailComponent = ({id}: { id: string }) => {
    // const sportBasicData = eventApi.getSportEckDaten(id);
    // const eventList = eventApi.getEventsByCategory(id);

    const token = theme.useToken().token;

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
                                  style={{color: token.colorPrimary}}>Sport</Typography.Title>
                <Typography.Title level={5} className={"tree-content-sub-title"}
                                  style={{color: token.colorTextSecondary}}
                >Parent Sport</Typography.Title>

            </Flex>
            <Button
                type={"primary"}
                icon={<IconPlus size={20}/>}
                onClick={() => {
                    //TODO eventApi.addEvent(id);
                }
                }
            >Hinzufügen</Button>
        </Flex>
            <Flex
                gap={10}
            >
                <SportsNumberComponent count={1000} description={"Anzahl der Events"} color={token.colorBgContainer}/>
            </Flex>
            <Typography.Title level={4}>Eventvorschau</Typography.Title>
            <Flex
                vertical
                className={"tree-content-table"}
                gap={20}
            >
                {
                    data.map((event) => (
                        <Row key={event.id}
                             gutter={[8, 8]}
                             wrap
                             justify={"space-between"}
                        >
                            <Col flex="0 0 100px" style={{background: token.colorPrimary}}>
                                <Typography.Text>{convertToSwissDate(event.date)}</Typography.Text>
                            </Col>
                            <Col flex="1 1 300px"  style={{
                                background: token.colorBgContainer}}>
                                <Typography.Text>{event.name}</Typography.Text>
                            </Col>
                            <Col
                                flex={"0 0 auto"}
                            >
                                <Button
                                    icon={<IconPlus size={20}/>}
                                    type={"primary"}
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
                        //TODO eventApi.addEvent(id);
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
}

const data: Event[] = [
    {
        id: '1',
        date: '2021-09-01',
        name: 'Young Boys vs FC Basel',
    },
    {
        id: '2',
        date: '2021-09-01',
        name: 'FC Basel vs FC Zürich',
    },
    {
        id: '3',
        date: '2021-09-01',
        name: 'FC Zürich vs FC Luzern',
    }
];