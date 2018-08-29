import React, { Component } from 'react';
import { Table, Button } from 'semantic-ui-react';
import web3 from '../ethereum/web3';
import CryptoCoupon from '../ethereum/cryptoCoupon';

class CouponRow extends Component {
  onApprove = async () => {
    const cryptoCoupon = CryptoCoupon(this.props.address);

    const accounts = await web3.eth.getAccounts();
    /*await campaign.methods.approveRequest(this.props.id).send({
      from: accounts[0]
    });*/
  };

  onFinalize = async () => {
    const cryptoCoupon = CryptoCoupon(this.props.address);

    const accounts = await web3.eth.getAccounts();
    await cryptoCoupon.methods.finalizeRequest(this.props.id).send({
      from: accounts[0]
    });
  };

  render() {
    const { Row, Cell } = Table;
    const { id, coupon } = this.props;
    //const readyToFinalize = request.approvalCount > approversCount / 2;

    return (
      <Row
        disabled={coupon.gift}
        
      >
        <Cell>{id}</Cell>
        <Cell>{coupon.name}</Cell>
        <Cell>{coupon.description}</Cell>
        <Cell>
          {coupon.serialNumber}
        </Cell>
        <Cell>{web3.utils.fromWei(coupon.value, 'ether')}</Cell>
        <Cell>
          {coupon.gift ? (
            <Button color="green" basic>
              Approve
            </Button>
          ): null}
        </Cell>
        <Cell>
          {coupon.gift ? (
            <Button color="teal" basic >
              Burn
            </Button>
          ) : null}
        </Cell>
      </Row>
    );
  }
}

export default CouponRow;
