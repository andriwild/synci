import {Alert, Flex, Spin, Typography} from "antd";

/** Centered spinner used while the sport tree loads (desktop and mobile). */
export const LoadingState = ({text = "Lade Sportarten..."}: { text?: string }) => (
    <Flex vertical justify={"center"} align={"center"} gap={12} style={{width: "100%", padding: "40px var(--page-gutter)"}}>
        <Spin size={"large"}/>
        <Typography.Title level={4} style={{margin: 0}}>{text}</Typography.Title>
    </Flex>
);

export const ErrorState = ({error}: { error: unknown }) => (
    <Flex justify={"center"} align={"center"} style={{width: "100%", padding: "20px var(--page-gutter)"}}>
        <Alert
            message="Ups, es ist ein Fehler aufgetreten"
            description={error instanceof Error ? error.message : String(error ?? "")}
            type="error"
            showIcon
        />
    </Flex>
);
