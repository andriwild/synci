import {useEffect, useState} from "react";
import {Flex} from "antd";
import "./SportTreeComponent.css";
import {CaretRight} from "@phosphor-icons/react";
import {Sport} from "../../services/sport/entities/sport.ts";
import {sportApi} from "../../services/sport/sportApi.ts";
import {SportDetailComponent} from "./SportDetailComponent.tsx";


export const SportTreeComponent = () => {
    const [selectedId, setSelectedId] = useState("");
    const sportTree = sportApi.useGetAllQuery();
    const [treeColumns, setTreeColumns] = useState<Sport[][]>([sportTree.data || []]);

    useEffect(() => {
        if (sportTree.data) {
            setTreeColumns([sportTree.data]);
        }
    }, [sportTree.data]);


    if (sportTree.isLoading) {
        return <div>Loading...</div>;
    }
    if (sportTree.isError) {
        return <div>Error: {sportTree.error?.toString()}</div>;
    }

    const handleCategoryClick = (sport: Sport, level: number) => {
        setSelectedId(sport.id);
        const newTreeColumns = [...treeColumns.slice(0, level + 1)];

        if (sport.subSports && sport.subSports.length > 0) {
            newTreeColumns[level + 1] = sport.subSports;
        } else {
            newTreeColumns.length = level + 1;
        }

        setTreeColumns(newTreeColumns);
    };


    const columnColors = ["#3D5A80", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];
    return (
        <Flex id="tree-container">
            {treeColumns.map((categories: Sport[], index) => (
                <div
                    key={index}
                    className="tree-column"
                    style={{
                        background: columnColors[index] || "gray",
                    }}
                >
                    {categories.map((category: Sport) => (
                        <div
                            key={category.id}
                            className={`tree-item ${selectedId === category.id ? "selected" : ""}`}
                            onClick={() => handleCategoryClick(category, index)}
                        >
                            <Flex
                                style={{
                                    justifyContent: "space-between",
                                    alignItems: "center",
                                    padding: "1rem",
                                    width: "100%",
                                }}
                            >
                                <h4>{category.name}</h4>
                                {category.subSports.length > 0 && <CaretRight size={10}/>}
                            </Flex>
                        </div>
                    ))}
                </div>
            ))}

            <SportDetailComponent id={selectedId}/>
        </Flex>
    );
}