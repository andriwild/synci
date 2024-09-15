import {Button, Card, Flex, Form, List, Select, Typography} from "antd";
import {useNavigate, useParams} from "react-router-dom";
import {Copy, Plus} from "@phosphor-icons/react";

interface Team {
    id: string;
    name: string;
}
export type UserConfigValues = Team;

export const UserConfig = () => {
    const [form] = Form.useForm<UserConfigValues>();
    const navigate = useNavigate();
    const {id} = useParams();

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
                <Button onClick={() => navigate('/config')} style={{width: 40, height: 40, marginTop: 48, backgroundColor: '#1677ff', color: 'white'}} icon={<Plus size={'1rem'} />} />
                <List
                    style={{marginTop: 12}}
                    grid={{ gutter: 16}}
                    dataSource={dataSource}
                    renderItem={(item) => (
                        <List.Item>
                            <Card title={item.label} style={{width: 400, cursor: 'pointer'}} onClick={() => navigate(`config/${item.id}`)}>
                                <Flex gap={12} vertical>

                                    <Flex vertical>
                                        <Typography.Text strong>Mannschaften</Typography.Text>
                                        {item.teams.map((team) => {
                                            return <Typography.Text key={team}>{team}</Typography.Text>
                                        })}
                                    </Flex>
                                    <Flex vertical>
                                        <Typography.Text strong>Url</Typography.Text>
                                        <Typography.Paragraph copyable={{ icon: <Copy style={{ fontSize: '1.4rem' }} /> }}>
                                            {item.url}
                                        </Typography.Paragraph>

                                    </Flex>
                                </Flex>
                            </Card>
                        </List.Item>
                    )}
                />
        </Flex>
    );
};
