#!/user/bin/env bash
# Author: Uros Orozel
# Description: Assign LDAP admin to admin project and admin role
# Date: 24/11/2016

run_query(){
  SQL=$1
  # -B no frames, -N no column names
  mysql -D keystone -B -N  -e "${SQL}"
}

echo "Retrive roles/project/user ID's"
echo "========================================================"
LOCAL_ADMIN_USER=$1
LOCAL_ADMIN_ID=$(run_query "select user_id from local_user where name=\"${LOCAL_ADMIN_USER}\"")
LDAP_ADMIN_ID=$(run_query "select public_id from id_mapping where local_id=\"${LOCAL_ADMIN_USER}\"")
ADMIN_PROJECT_ID=$(run_query "select id from project where name=\"admin\" and parent_id=\"default\"")
ADMIN_ROLE_ID=$(run_query "select id from role where name=\"admin\"")
HEAT_ROLE_ID=$(run_query "select id from role where name=\"heat_stack_owner\"")

echo "Local admin ID: ${LOCAL_ADMIN_ID}"
echo "LDAP admin ID: ${LDAP_ADMIN_ID}"
echo "Admin project ID: ${ADMIN_PROJECT_ID}"
echo "Admin role ID: ${ADMIN_ROLE_ID}"
echo "Heat role ID: ${HEAT_ROLE_ID}"
echo "Assign LDAP admin, username: \"${LOCAL_ADMIN_USER}\" ID: \"${LDAP_ADMIN_ID}\" with admin and heat role"
echo "========================================================="
CHECK_ADMIN=$(run_query "select count(*) from assignment where actor_id=\"${LDAP_ADMIN_ID}\" and target_id=\"${ADMIN_PROJECT_ID}\" and role_id=\"${ADMIN_ROLE_ID}\"")
CHECK_HEAT=$(run_query "select count(*) from assignment where actor_id=\"${LDAP_ADMIN_ID}\" and target_id=\"${ADMIN_PROJECT_ID}\" and role_id=\"${HEAT_ROLE_ID}\"")

if [ $CHECK_ADMIN -eq 0 ];then
  ADMIN_ROLE=$(run_query "insert into assignment values(\"UserProject\",\"${LDAP_ADMIN_ID}\",\"${ADMIN_PROJECT_ID}\",\"${ADMIN_ROLE_ID}\")")
  echo "$ADMIN_ROLE"
else
  echo "LDAP admin is already assigned with admin role"
fi

if [ $CHECK_HEAT -eq 0 ];then
  HEAT_ROLE=$(run_query "insert into assignment values(\"UserProject\",\"${LDAP_ADMIN_ID}\",\"${ADMIN_PROJECT_ID}\",\"${HEAT_ROLE_ID}\")")
  echo "$HEAT_ROLE"
else
  echo "LDAP admin is already assigned with heat role"
fi
