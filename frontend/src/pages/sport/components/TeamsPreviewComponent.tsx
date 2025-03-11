import { Flex, Typography } from "antd";

export const TeamsPreviewComponent = ({ sportId } : { sportId: string }) => {
    return (
        <Flex
            vertical
            gap={10}
        >
            <Typography.Title level={4} style={{marginBottom: 0}}>Teamvorschau für {sportId}</Typography.Title>

        </Flex>
    );
}