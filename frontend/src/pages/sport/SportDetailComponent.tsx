import {Flex, Typography} from "antd";

export const SportDetailComponent = ({id}: { id: string }) => {
    if (!id) {
        return (
            <Flex
                vertical
                className="tree-content"
                style={{
                    justifyContent: "center",
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
        <div
            className="tree-content"
            style={{
                background: "white",
                borderRadius: "0 20px 20px 0",
                padding: "20px",
            }}
        >
            <Flex
                vertical
                style={{
                    justifyContent: "center",
                    alignItems: "center",
                    paddingTop: "20px",
                }}
            >
                <h2>Kategorie {id}</h2>
            </Flex>
        </div>
    );
};