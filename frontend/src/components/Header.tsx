import { FC } from "react";
import {Flex, Image, Layout, Menu, Space, theme, Typography} from "antd";
import {Link, useNavigate} from "react-router-dom";
import { MenuInfo } from "rc-menu/lib/interface";
import Title from "antd/es/typography/Title";

export const Header: FC = () => {
    const navigate = useNavigate();

    const items = [

        {
            key: '1',
            label: 'Sportarten',
            path: '/sport',
        },
        {
            key: '2',
            label: 'Meine Kalender',
            path: '/config',
        },
        {
            key: '3',
            label: 'Wie funktionierts?',
            path: '/faq',
        }
    ];

    const handleMenuClick = (e: MenuInfo) => {
        const clickedItem = items.find(item => item.key === e.key);
        if (clickedItem && clickedItem.path) {
            navigate(clickedItem.path);
        }
    };

    const { token } = theme.useToken();
    return (
        <Layout.Header style={{ display: 'flex', alignItems: 'center', justifyContent:'space-between', padding: ' 0 24px', backgroundColor: 'white', margin:'20px 20px 0px 20px', borderRadius:  token.borderRadius }}>
           <Space>
            <Image
                src={ './assets/Logo_synci.png' }
                preview={ false }
                style={{
                    cursor: 'pointer',
                    padding: '10px 20px 10px 0',
                    maxHeight: 60 }}
                onClick={ () => {
                        navigate('/');
                }
                }
            />
            <Menu
                mode="horizontal"
                defaultSelectedKeys={ ['1'] }
                items={ items }
                onClick={ handleMenuClick }
                style={{ flex: 1, minWidth: 0, backgroundColor: 'white' }}

            />
            </Space>
                <Link to={'/config/new'}>
                    <Flex style={{ alignItems: 'center', cursor: 'pointer', gap: 10 }}>
                    <Flex style={{ flexDirection: 'column', alignItems: 'flex-end' }}>
                    <Typography.Text type={'secondary'} style={{margin: 0}}>Mein Konto</Typography.Text>
                    <Title level={5} style={{margin: 0}} color={token.colorPrimary}>Elias Bräm</Title>
                    </Flex>
                        <Image
                            src={ './assets/Profile_sample.png' }
                            preview={ false }
                            style={{
                                cursor: 'pointer',
                                borderRadius: '50%',
                                height: 40,
                                width: 40,
                                objectFit: 'cover',
                            }}
                            onClick={ () => {
                                navigate('/');
                            }
                            }
                        />
                    </Flex>
                </Link>


        </Layout.Header>
    );
};
