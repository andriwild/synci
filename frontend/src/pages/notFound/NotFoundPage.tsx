import {Button, Flex, Typography} from "antd";
import {Link} from "react-router-dom";
import {usePageMeta} from "../../utils/usePageMeta.ts";

export const NotFoundPage = () => {
    usePageMeta({title: "Seite nicht gefunden", noindex: true});

    return (
        <Flex vertical align={"center"} gap={16} style={{width: "100%", padding: "60px 20px", textAlign: "center"}}>
            <Typography.Title level={1} style={{margin: 0}}>Seite nicht gefunden</Typography.Title>
            <Typography.Text>Die angeforderte Seite existiert nicht oder wurde verschoben.</Typography.Text>
            <Flex gap={10} wrap justify={"center"}>
                <Link to="/"><Button type={"primary"}>Zur Startseite</Button></Link>
                <Link to="/sport"><Button>Sportarten entdecken</Button></Link>
            </Flex>
        </Flex>
    );
};
