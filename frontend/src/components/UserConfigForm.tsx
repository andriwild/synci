import { Button, Card, Flex, Form, Select } from "antd";
import {useNavigate} from "react-router-dom";

interface Team {
    id: string;
    name: string;
}
export type UserConfigValues = Team;

export const UserConfigForm = () => {
    const [form] = Form.useForm<UserConfigValues>();
    const navigate = useNavigate();

    const teams: Team[] = [
        { id: 'teamA', name: 'Team A' },
        { id: 'teamB', name: 'Team B' },
        { id: 'teamC', name: 'Team C' },
    ];

    const handleSubmit = (values: UserConfigValues) => {
        console.log('Form submitted:', values);
    };

    const handleBack = () => {
        console.log('Zurück-Button geklickt');
        navigate('/');
    };

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24, justifyContent: "center", alignItems: 'center'}}>
        <Card style={{ width: 600, textAlign: 'left' }}>
            <h2 style={{ marginBottom: '20px' }}>Benutzerkonfigurationen</h2>
            <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder
                welche Sportart du dich interessierst</p>
            <Form<UserConfigValues> form={form} onFinish={handleSubmit} layout={'vertical'} style={{marginTop: 36}}>
                <Form.Item name={'teams'} label={'Teams'}>
                    <Select
                        options={teams.map((team) => ({
                            label: team.name,
                            value: team.id,
                        }))}
                        style={{ width: 300 }}
                        mode="multiple"
                        showSearch
                        allowClear
                        filterOption={(input, option) =>
                            (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                        }
                        placeholder="Wähle ein Team aus"
                    />
                </Form.Item>
                <Flex gap={'middle'} justify={'end'} style={{marginTop: 48, marginBottom: 12 }}>
                    <Button onClick={handleBack}>
                        Zurück
                    </Button>
                    <Button htmlType={'submit'} type={'primary'}>
                        Submit
                    </Button>
                </Flex>
            </Form>
        </Card>
        </Flex>
    );
};
