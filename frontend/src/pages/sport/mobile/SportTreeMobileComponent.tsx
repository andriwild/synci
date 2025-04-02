import {useState} from "react";
import "./SportTreeMobileComponent.css";
import {Sport} from "../../../services/sport/entities/sport.ts";
import {sportApi} from "../../../services/sport/sportApi.ts";
import {Alert, Flex, Spin} from "antd";
import {CaretRight} from "@phosphor-icons/react";
import {SportDetailMobileComponent} from "./SportDetailMobileComponent.tsx";

export const SportTreeMobileComponent = () => {
    const {data, isLoading, isError, error} = sportApi.useGetAllQuery();
    const [expandedIds, setExpandedIds] = useState<string[]>([]);

    const [selectedSport, setSelectedSport] = useState<Sport | null>(null);

    const toggleExpand = (sport: Sport) => {

        if (sport && sport.subSports.length === 0) {
            setSelectedSport(sport);
            return;
        }
        setExpandedIds((prev) =>
            prev.includes(sport.id) ? prev.filter((i) => i !== sport.id) : [...prev, sport.id]
        );
    };


    const columnColors = ["#3D5A80", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];

    const renderTree = (sports: Sport[], level = 0) => {
        return sports.map((sport) => (
            <div key={sport.id}>
                <Flex
                    justify={"space-between"}
                    className="tree-item"
                    onClick={() => toggleExpand(sport)}
                    style={{
                        display: "flex",
                        width: "100%",
                        padding: "15px",
                        borderBottom: "1px solid darkgrey",
                        justifyContent: "space-between",
                        cursor: "pointer",
                        backgroundColor: columnColors[level % columnColors.length],
                    }}
                >

                    <span style={level === 0 ? {color: "white"} : {}}>{sport.label}</span>
                    {sport.subSports.length > 0 &&  <CaretRight
                        size={14}
                        onClick={(e) => {
                            e.stopPropagation();
                            setSelectedSport(sport);
                        }}
                        style={level === 0 ? {color: "white"} : {}}/>}

                </Flex>
                {expandedIds.includes(sport.id) &&
                    sport.subSports.length > 0 &&
                    renderTree(sport.subSports, level + 1)}
            </div>
        ));
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
        </div>
    );
}