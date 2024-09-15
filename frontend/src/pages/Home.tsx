import { useNavigate } from "react-router-dom";
import {Button, Card, Flex, List, Typography} from "antd";

export const Home = () => {
    const navigate = useNavigate();

    const dataSource = [
        {
            id: '1',
            label: 'SuperLeague Spiele',
            teams: ['YoungBoys, Basel, Zürich, Lausanne'],
            url: 'https://google.ch',
        },
        {
            id: '2',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '3',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '4',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '5',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '6',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
    ];

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
            <Typography.Title>Synci</Typography.Title>
            <Typography.Text>Willkommen bei Synci...</Typography.Text>
            <List
                style={{marginTop: 48}}
                grid={{ gutter: 16}}
                dataSource={dataSource}
                renderItem={(item) => (
                    <List.Item>
                        <Card title={item.label} style={{width: 400}} onClick={() => navigate(`edit/${item.id}`)}>
                            <Flex gap={12} vertical>

                            <Flex vertical>
                                <Typography.Text strong>Mannschaften</Typography.Text>
                                {item.teams.map((team) => {
                                    return <Typography.Text key={team}>{team}</Typography.Text>
                                })}
                            </Flex>
                            <Flex vertical>
                            <Typography.Text strong>Url</Typography.Text>
                                <Typography.Paragraph copyable>{item.url}</Typography.Paragraph>

                            </Flex>
                            </Flex>
                        </Card>
                    </List.Item>
                )}
            />
            <Button onClick={() => navigate('/config')} style={{width: 200}}>Config erstellen</Button>
        </Flex>
    );
};
