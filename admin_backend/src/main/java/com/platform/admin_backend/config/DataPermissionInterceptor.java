package com.platform.admin_backend.config;

import com.baomidou.mybatisplus.core.plugins.InterceptorIgnoreHelper;
import com.baomidou.mybatisplus.core.toolkit.PluginUtils;
import com.baomidou.mybatisplus.extension.plugins.inner.InnerInterceptor;
import com.platform.admin_backend.common.UserContextHolder;
import com.platform.admin_backend.enums.RoleEnum;
import net.sf.jsqlparser.expression.LongValue;
import net.sf.jsqlparser.expression.operators.relational.EqualsTo;
import net.sf.jsqlparser.expression.operators.relational.InExpression;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.schema.Column;
import net.sf.jsqlparser.schema.Table;
import net.sf.jsqlparser.statement.select.PlainSelect;
import net.sf.jsqlparser.statement.select.Select;
import net.sf.jsqlparser.statement.select.SelectExpressionItem;
import net.sf.jsqlparser.statement.select.SubSelect;
import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;
import java.sql.SQLException;

public class DataPermissionInterceptor implements InnerInterceptor {
    private static final String PROJECT_TABLE = "project";

    @Override
    public void beforeQuery(Executor executor, MappedStatement ms, Object parameter,
                            RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql)
            throws SQLException {
        if (InterceptorIgnoreHelper.willIgnoreDataPermission(ms.getId())) return;
        UserContextHolder.UserContext ctx = UserContextHolder.get();
        if (ctx == null) return;
        RoleEnum role = ctx.getRole();
        if (role == RoleEnum.SUPER_ADMIN || role == RoleEnum.ADMIN) return;
        String originalSql = boundSql.getSql();
        try {
            String modifiedSql = addDataPermission(originalSql, ctx.getUserId());
            PluginUtils.MPBoundSql mpBs = PluginUtils.mpBoundSql(boundSql);
            mpBs.sql(modifiedSql);
        } catch (Exception e) {
            System.err.println("DataPermission error: " + e.getMessage());
        }
    }

    private String addDataPermission(String originalSql, Long userId) throws Exception {
        String lowerSql = originalSql.toLowerCase();
        if (!lowerSql.contains(PROJECT_TABLE)) return originalSql;
        var statement = CCJSqlParserUtil.parse(originalSql);
        if (!(statement instanceof Select selectStmt)) return originalSql;
        if (!(selectStmt.getSelectBody() instanceof PlainSelect plainSelect)) return originalSql;

        PlainSelect subPlain = new PlainSelect();
        subPlain.addSelectItems(new SelectExpressionItem(new Column("project_id")));
        subPlain.setFromItem(new Table("project_member"));
        subPlain.setWhere(new EqualsTo(new Column("user_id"), new LongValue(userId)));
        SubSelect subSelect = new SubSelect();
        subSelect.setSelectBody(subPlain);
        InExpression inExpr = new InExpression();
        inExpr.setLeftExpression(new Column("id"));
        inExpr.setRightExpression(subSelect);

        if (plainSelect.getWhere() == null) {
            plainSelect.setWhere(inExpr);
        } else {
            plainSelect.setWhere(new net.sf.jsqlparser.expression.operators.conditional.AndExpression(
                    plainSelect.getWhere(), inExpr));
        }
        return selectStmt.toString();
    }
}