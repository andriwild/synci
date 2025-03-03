import {useState} from "react";
import {Flex} from "antd";
import "./SportTreeComponent.css";
import {sampleSportTree, SportCategory} from "../../services/category/entities/tree_sample.ts";
import {CaretRight} from "@phosphor-icons/react";

export const SportTreeComponent = () => {
    const [selectedId, setSelectedId] = useState(0);
    const [treeColumns, setTreeColumns] = useState([sampleSportTree]);

    const handleCategoryClick = (category : SportCategory, level : number) => {
        setSelectedId(category.id);

        const newTreeColumns = [...treeColumns.slice(0, level + 1)];

        if (category.subcategories.length > 0) {
            newTreeColumns[level + 1] = category.subcategories;
        } else {
            newTreeColumns.length = level + 1; // Entfernt unnötige Spalten
        }

        setTreeColumns(newTreeColumns);
    };

    const columnColors = ["#3D5A80", "#C5CDD9", "#D8DEE6", "#E9EDF0", "#F2F4F6"];

    return (
        <Flex id={"tree-container"}>
            {treeColumns.map((categories, index) => (
                <div
                    key={index}
                    className="tree-column"
                    style={{
                        background: columnColors[index] || "gray",
                    }}
                >
                    {categories.map((category) => (
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
                                {category.subcategories.length > 0 &&
                                    <CaretRight size={10} />
                                }
                            </Flex>
                        </div>
                    ))}
                </div>
            ))}
            <div className="tree-content" style={{
                background: "white",
                borderRadius: "0 20px 20px 0",
                padding: "20px",
            }}>
                {selectedId === 0 ?
                    <Flex
                        vertical
                        style={{
                            justifyContent: "center",
                            alignItems: "center",
                            paddingTop: "20px",

                        }}
                    >
                    <h2>Willkommen!</h2>
                    <p>Bitte wählen Sie eine Kategorie aus.</p>
                    </Flex>


                    :
                    <Flex
                        vertical
                        style={{
                            justifyContent: "center",
                            alignItems: "center",
                            paddingTop: "20px",

                        }}
                    >
                        <h2>Kategorie {selectedId}</h2>
                        <p>Das ist eine Beschreibung der Kategorie.</p>
                    </Flex>
                }
            </div>
        </Flex>
    );
};
