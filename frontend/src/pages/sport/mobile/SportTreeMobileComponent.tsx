import {useState} from "react";
import "./SportTreeMobileComponent.css";
import {Sport} from "../../../services/sport/entities/sport.ts";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {Alert, Button, Flex, Spin, theme} from "antd";
import {ArrowRight, CaretDown, CaretUp} from "@phosphor-icons/react";
import {SportDetailMobileComponent} from "./SportDetailMobileComponent.tsx";
import {ShowCalendarsButton} from "./ShowCalendarsButton.tsx";

export const SportTreeMobileComponent = () => {
    const {data, isLoading, isError, error} = sportApi.useGetAllQuery();
    const [expandedIds, setExpandedIds] = useState<string[]>([]);
    const token = theme.useToken().token;

    const [selectedSport, setSelectedSport] = useState<Sport | null>(null);

    const toggleExpand = (sport: Sport) => {
        if (sport.subSports.length === 0) return;
        setExpandedIds((prev) =>
            prev.includes(sport.id) ? prev.filter((i) => i !== sport.id) : [...prev, sport.id]
        );
    };


    const columnColors = ["#b2bdcf", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];
    const renderTree = (sports: Sport[], level = 0) => {
        return sports.map((sport) => {
            const hasSub = sport.subSports.length > 0;
            const isExpanded = expandedIds.includes(sport.id);
            return (
                <div key={sport.id}>
                    <Flex
                        justify={"space-between"}
                        align={"center"}
                        className="tree-item"
                        onClick={() => hasSub ? toggleExpand(sport) : setSelectedSport(sport)}
                        style={{
                            display: "flex",
                            width: "100%",
                            padding: "15px",
                            borderBottom: "1px solid darkgrey",
                            justifyContent: "space-between",
                            cursor: "pointer",
                            gap: 10,
                            backgroundColor: columnColors[level % columnColors.length],
                        }}
                    >
                        <Flex align={"center"} gap={10} style={{minWidth: 0}}>
                            {hasSub ? (
                                <Button
                                    type={"text"}
                                    size={"small"}
                                    style={{padding: 0, height: "auto"}}
                                    icon={isExpanded
                                        ? <CaretUp size={16} color={"black"}/>
                                        : <CaretDown size={16} color={"black"}/>}
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        toggleExpand(sport);
                                    }}
                                />
                            ) : (
                                <span style={{display: "inline-block", width: 16}}/>
                            )}
                            <span>{sport.label}</span>
                        </Flex>
                        <Button
                            shape={"circle"}
                            style={{background: token.colorBgContainer, flexShrink: 0}}
                            icon={<ArrowRight size={16} color={token.colorPrimary}/>}
                            onClick={(e) => {
                                e.stopPropagation();
                                setSelectedSport(sport);
                            }}
                        />
                    </Flex>
                    {isExpanded && hasSub && renderTree(sport.subSports, level + 1)}
                </div>
            );
        });
    };

    if (isLoading) {
        return <Spin size="large"/>;
    }

    if (isError) {
        return (
            <Flex
                style={{
                    justifyContent: "center",
                    alignItems: "center",
                    height: "100%",
                    width: "100%",
                }}
            >
                <Alert
                    message="Ups, es ist ein Fehler aufgetreten"
                    description={error?.toString()}
                    type="error"
                    showIcon
                />
            </Flex>
        );
    }

    return (
        <div style={{width: "100%" }}>
            {selectedSport ? <SportDetailMobileComponent callback={setSelectedSport} id={selectedSport.id} title={selectedSport.label}/>
                : (
                <Flex
                    vertical
                    className={`tree-container`}
                    style={{ width: "100%" }}
                >
                    {data && data.length > 0 ? renderTree(data) : <p>Keine Sportarten gefunden</p>}
                </Flex>
            )}
            <ShowCalendarsButton />
        </div>
    );
}