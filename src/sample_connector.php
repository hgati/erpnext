<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
require_once '../curl/Zebra_cURL.php';
require_once '../app/Mage.php';
Mage::app();

class action extends Zebra_cURL{

	function login(){

		// LOGIN: update your details here:
		$this->erpUrl = 'https://test.example.com/';
		$username = 'test@example.com';
		$password = 'test-password';

		$this->api_resource = 'api/resource/';

		return $this->post(array(
			$this->erpUrl.'api/method/login'  =>  array(
				'usr'  =>  $username,
				'pwd'  =>  $password,
			)));
	}

	function getDocumentAll($docType,$limit_start,$limit_page_length,$fields){ // Get All data
		if($limit_page_length != '' ||  $limit_start != '' || count($fields) > 0){
			$fields = implode('","',$fields);
			$fields = '"'.$fields.'"';
			$param = '?';
			$param .= ($limit_page_length != '') ? 'limit_page_length='.$limit_page_length.'&' : '';
			$param .= ($limit_start != '') ? 'limit_start='.$limit_start.'&' : '';
			$param .= (count($fields) > 0) ? 'fields=['.$fields.']' : '';
		}else{
			$param = '';
		}
		// echo $param;exit;
		return $this->get(array(
			$this->erpUrl.$this->api_resource.$docType.$param));
		// print_r($a);
	}

	function getDocumentById($docType,$id){ // Get All data
		return $this->get(array(
			$this->erpUrl.$this->api_resource.$docType.'/'.$id));
	}

	function getDocumentFields($docType,$param){  // Get data filtered by fields $param in json format ex:- '["name"]'
		$this->get(array(
			$this->erpUrl.$this->api_resource.$docType.'/?filters='.$param));
	}

	function getDocumentFilter($docType,$field,$operator,$value){  // Get data filtered by feilds $param in json format ex:- '["name"]'

		$param = '?filters=[["'.$docType.'", "'.$field.'", "'.$operator.'", "'.$value.'"]]';

		$this->get(array(
			$this->erpUrl.$this->api_resource.$docType.'/'.$param));
	}

	function createDocument($docType,$jsonData){  // Create data
		$a = $this->post(array(
			$this->erpUrl.$this->api_resource.$docType  =>  array(
				'data'  =>  $jsonData,
			)));
		//print_r($a);exit;
	}

	function updateDocument($docType,$jsonData,$id){ // Update data
		$this->put(array(
			$this->erpUrl.$this->api_resource.$docType.'/'.$id  =>  array(
				'data'  =>  $jsonData,
			)));
	}

	function getJson($array){
		return json_encode($array);
	}


	function getProductCollection(){
		return Mage::getModel('catalog/product')->getCollection();
	}

	function loadProduct($_product){
		return Mage::getModel('catalog/product')->loadByAttribute('sku',$_product->item_code);
	}

	function updateSingleProduct($sku){

		if($sku){
			$e_product = $this->getDocumentById('Item',$sku);
			$e_product = json_decode($e_product->body);
			$e_product = $this->updateProduct($e_product->data);
		}

	}
	function updateAllProduct($docType,$limit_start,$limit_page_length,$fields){ // Update All product
		$e_product = $this->getDocumentAll($docType,$limit_start,$limit_page_length,$fields);
		$e_product = json_decode($e_product->body);

	}

	function updateProductStock($docType,$limit_start,$limit_page_length,$fields){ // Update All product stock
		$e_product = $this->getDocumentAll($docType,$limit_start,$limit_page_length,$fields);
		$e_product = json_decode($e_product->body);

		$collection = $e_product->data->items;
		foreach ($collection as $_product) {

			$this->updateStock($_product);
		}
	}
	function getProductStock($product){
		return Mage::getModel('cataloginventory/stock_item')->loadByProduct($product);
	}

	function updateStock($_product){
		$product = $this->loadProduct($_product);
		$stock = $this->getProductStock($product);
		try{
			if($_product->qty > 0){ $stock->setIsInStock(1); }else{ $stock->setIsInStock(0); }
			$stock->setQty($_product->qty)->save();
			echo 'done';
		}
		catch(Exception $e){
			echo 'a';
			echo $e->getMessage();
		}

	}

	function updateProduct($e_product){

		$product = $this->loadProduct($e_product);
		$product->setName($e_product->item_name);
		try{
			$product->save();
			echo 'done';
		}catch(Exception $e){
			echo $e->getMessage();
		}
	}


	function getCustomerCollection(){
		return Mage::getModel('customer/customer')->getCollection()->addAttributeToSelect('*');
	}

	function getErpCustomer(){
		echo '<pre>';
		$cust = $this->getDocumentById('Customer','yash');
		print_r($cust);exit;
	}

	function writeNewCustomers(){

		foreach ($this->getCustomerCollection() as $customer) {
			$data =  array(
				'customer_name' => $customer->getFirstname().' '.$customer->getLastname().'-'.$customer->getId() ,
				'customer_group' => 'Individual',
				'customer_type' => 'Individual',
				'territory' => 'India',
				'company' => 'Test Company',
			);

			$data = $this->getJson($data);
			try{
				$this->createDocument('Customer',$data);
			}
			catch(Exception $e){
				echo $e->getMessage();
			}
		}
	}

	function writeNewCustomerAddress(){

		foreach ($this->getCustomerCollection() as $customer) {

			$billing_address = $customer->getDefaultBillingAddress();

			if($billing_address){

				$data =  array(
					'address_line1' => $billing_address->getData('street'),
					'city' => $billing_address->getCity(),
					'phone' => $billing_address->getTelephone(),
				);
				echo $doc = 'Address/'.$customer->getFirstname().' '.$customer->getLastname().'-Billing';
				$data = $this->getJson($data);
				print_r($data);exit;
				try{
					$this->createDocument($doc,$data);
				}
				catch(Exception $e){
					echo $e->getMessage();
				}
			}
		}
	}

	function writeOrders(){

		$orders = Mage::getModel('sales/order')->getCollection();

		$items = array();
		foreach ($orders as $order) {

			if($order->getCustomerGroupId() == 0){ continue; }
			$ordered_items = $order->getAllItems();

			foreach($ordered_items as $item){
				$sku = $item->getSku();
				$items[] = array('item_code'=>$sku);
			}

			$data =  array(
				'customer' => $order->getCustomerFirstname() ,
				'delivery_date' => date('Y-m-d'),
				'items'=> array($items));


			$data = $this->getJson($data);

			try{
				$this->createDocument('Sales Order',$data);

			}
			catch(Exception $e){
				echo $e->getMessage();
			}
		}
	}

	function pushCustomer($customer){
		$data =  array(
			'customer_name' => $customer->getFirstname().' '.$customer->getLastname().'-'.$customer->getId() ,
			'customer_group' => 'Individual',
			'customer_type' => 'Individual',
			'territory' => 'India',
			'company' => 'Test Company',
			'status' => 'Submitted',
		);

		$data = $this->getJson($data);
		try{
			echo 'a';
			$result = $this->createDocument($this->docCustomer,$data);
		}
		catch(Exception $e){
			echo 'b';
				$result = $e->getMessage();
		}

		return $result;
	}

	function pushAllCustomer(){
		$customers = Mage::getModel('customer/customer')->getCollection();

		foreach ($customers as $customer) {
			$this->pushCustomer($customer);
		}
	}

}
$obj->cookies('/tmp/cookies.txt',true);
$obj->login();
//$obj->updateProductStock('Stock%20Entry/STE-00001');
// $obj->writeOrders();
// $obj->writeOrders();
